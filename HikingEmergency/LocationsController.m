//
//  LocationsController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 15.11.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "LocationsController.h"

@implementation LocationsController

static LocationsController *sharedInstance = nil;
static dispatch_queue_t socketQueue;

@synthesize isFirstLocation;
@synthesize isConnected;
@synthesize isSMSEnabled;
@synthesize lastLocation;
@synthesize timer;
@synthesize smsTimer;
@synthesize route;
@synthesize radius;
@synthesize udpSocket;
@synthesize tcpSocket;
@synthesize serverIP;
@synthesize serverTCPPort;
@synthesize serverUDPPort;
@synthesize phoneNumber;
@synthesize emergencyPhoneNumber;
//@synthesize routeAlert;
//@synthesize smsAlert;
@synthesize observers;

+(LocationsController*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance setIsFirstLocation:YES];
        [sharedInstance setIsConnected:NO];
        //get safety radius from settings
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [sharedInstance setRadius: [formatter numberFromString: [standardUserDefaults objectForKey:@"radius"]]];
        [sharedInstance setServerIP:[standardUserDefaults objectForKey:@"serverIP"]];
        [sharedInstance setServerTCPPort:[standardUserDefaults objectForKey:@"serverPort"]];
        [sharedInstance setServerUDPPort:[standardUserDefaults objectForKey:@"serverUDPPort"]];
        [sharedInstance setPhoneNumber: [standardUserDefaults objectForKey:@"userPhoneNumber"]];
        [sharedInstance setEmergencyPhoneNumber:[standardUserDefaults objectForKey:@"emergencyPhoneNumber"]];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                          target:self
                                                        selector:@selector(sendLocation)
                                                        userInfo:sharedInstance
                                                         repeats:YES];
        
        //user will be asked to send SMS with his location only once every 10 minutes (except for emergencies)
        NSTimer *smsTimer = [NSTimer scheduledTimerWithTimeInterval:600.0
                                                          target:self
                                                        selector:@selector(resetSMSEnabled)
                                                        userInfo:sharedInstance
                                                         repeats:YES];
        
        socketQueue = dispatch_queue_create("socketQueue", NULL);
        
        [sharedInstance setTcpSocket:[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue]];
        [sharedInstance setTimer: timer];
        [sharedInstance setSmsTimer:smsTimer];
        [sharedInstance setUdpSocket:[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:socketQueue]];
        NSError *error = nil;
        if (![[sharedInstance tcpSocket] connectToHost:[sharedInstance serverIP] onPort:[[sharedInstance serverTCPPort] intValue] error:&error])
        {
            [sharedInstance setIsConnected:NO];
            NSLog(@"Error connecting, will try again soon: %@", error);
        } else {
            [sharedInstance setIsConnected:YES];
        }
        
    }
    return sharedInstance;
}

- (void)addLocation:(CLLocationCoordinate2D) location {
    lastLocation = location;
}

- (void) reconnect {
    NSError *error = nil;
    if (![[sharedInstance tcpSocket] connectToHost:[sharedInstance serverIP] onPort:[[sharedInstance serverTCPPort] intValue] error:&error])
    {
        [sharedInstance setIsConnected:NO];
        NSLog(@"Error connecting, will try again soon: %@", error);
    } else {
        [sharedInstance setIsConnected:YES];
    }
}

+(void) resetSMSEnabled {
    [sharedInstance setIsSMSEnabled:YES];
}

+(void) sendLocation {
    if ([sharedInstance isNavigating]) {
        //step 1 - insert location into DB
        [[DBManager getSharedInstance] insertUserLocation:[sharedInstance lastLocation]];
        
        //step 2 - check if user is within specified radius from his route
        if (![sharedInstance isInRange:[sharedInstance lastLocation]]) {
//            [sharedInstance setRouteAlert:[[UIAlertView alloc] initWithTitle:@"Get back on track!"
//                                                            message:@"You are too far away from route"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:@"Help Me!" ,nil]];
//            //if not display alert window
//            [[sharedInstance routeAlert] show];
            [sharedInstance notifyObserversRoute];
        }
        
        //create message string
        NSString *message;
        NSData *data;
        if ([sharedInstance isFirstLocation]) {
            message = [sharedInstance getHiWithLastLocation];
        } else {
            message = [sharedInstance getLastLocationMessage];
        }
        data = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        //step 3 - try sending location via TCP
        if ([sharedInstance isConnected]) {
            [[sharedInstance tcpSocket] writeData:data
                                      withTimeout:-1
                                              tag:1];
            NSLog(@"Message %@ sent using TCP", message);
        } else {
            
            //step 4 - if sending via TCP fails - send via UDP and via SMS
            [[sharedInstance udpSocket] sendData:data
                                          toHost:[sharedInstance serverIP]
                                            port:[[sharedInstance serverUDPPort] intValue]
                                     withTimeout:-1
                                             tag:2];
            NSLog(@"Message %@ sent using UDP", message);
            
            if ([sharedInstance isSMSEnabled]) {
//            [sharedInstance setSmsAlert:[[UIAlertView alloc] initWithTitle:@"Can't connect using TCP connection"
//                                                                     message:@"Do you want to send location via SMS>"
//                                                                    delegate:self
//                                                           cancelButtonTitle:@"No"
//                                                           otherButtonTitles:@"Yes" ,nil]];
//            [[sharedInstance smsAlert] show];
                [sharedInstance notifyObserversSms];
            }
            //try reconnecting to host via tcp
            [sharedInstance reconnect];
        }
    }
}

//-(void) sendSMSWithLastLocation {
//    [sharedInstance sendSMSWithMessage:[sharedInstance getLastLocationMessage]];
//}

//-(void) sendSMSWithMessage: (NSString*) message {
//    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
//    if([MFMessageComposeViewController canSendText])
//    {
//        controller.body = message;
//        NSMutableArray* contactsPhoneNumbers = [[NSMutableArray alloc] init];
//        [contactsPhoneNumbers addObject:[sharedInstance emergencyPhoneNumber]];
//        controller.recipients = contactsPhoneNumbers;
//        controller.messageComposeDelegate = self;
//    } else {
//        NSLog(@"Can't send SMS");
//    }
//
//}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (alertView == [sharedInstance routeAlert]) {
//        if (buttonIndex == 0) {
//            NSLog(@"OK Tapped.");
//        }
//        else if (buttonIndex == 1) {
//            NSLog(@"Help Me! Tapped. Sending Emergency!");
//            [sharedInstance sendEmergencyWithLastKnownLocation];
//        }
//    }
//    if (alertView == [sharedInstance smsAlert]) {
//        if (buttonIndex == 0) {
//            NSLog(@"No Tapped.");
//        }
//        else if (buttonIndex == 1) {
//            NSLog(@"Yes Tapped, sending SMS");
//            [sharedInstance sendSMSWithLastLocation];
//        }
//    }
//}
//emergencies will be send via tcp, udp and sms simultaneously

- (void)sendEmergencyWithLastKnownLocation {
    NSString *message;
    NSData *data;
    message = [sharedInstance getEmergencyWithLastLocation];
    data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //step 1 - send via TCP
    [[sharedInstance tcpSocket] writeData:data
                              withTimeout:-1
                                      tag:1];
    NSLog(@"Message %@ sent using TCP", message);
    
    //step 2 - send via UDP
    [[sharedInstance udpSocket] sendData:data
                                  toHost:[sharedInstance serverIP]
                                    port:[[sharedInstance serverUDPPort] intValue]
                             withTimeout:-1
                                     tag:2];
    NSLog(@"Message %@ sent using UDP", message);
    //send via SMS

    //[sharedInstance sendSMSWithMessage:message];
}

-(BOOL) isInRange:(CLLocationCoordinate2D) location {
    CLLocation *usersLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    BOOL result = NO;
    //current user's location coordinates
    float xp = location.latitude;
    float yp = location.longitude;
    if (route) {
        for (int i = 0; i < ([[route getRoutePoints] count] - 1); i++) {
            
            //for each pair of route points
            MapPin *p1 = [[route getRoutePoints] objectAtIndex:i];
            float x1 = [p1 coordinate].latitude;
            float y1 = [p1 coordinate].longitude;
            MapPin *p2 = [[route getRoutePoints] objectAtIndex:i+1];
            float x2 = [p2 coordinate].latitude;
            float y2 = [p2 coordinate].longitude;
            
            //straight line Ax + By + C = 0 passing through points p1 and p2
            
            // A = (y2 - y1) / (x2-x1)
            float A1 = (y2 - y1) / (x2-x1);
            // B = -1
            float B1 = -1;
            // C = y1 - ((y2-y1)*x1)/(x2-x1)
            float C1 = y1 - ((y2-y1)*x1)/(x2-x1);
            
            //perpendicular line passing through current user's location
            
            //A2 = - 1/A1
            float A2 = -(1/A1);
            //B2 = -1
            float B2 = -1;
            //C2 = - A2 * xp - B2 * yp
            float C2 = - A2 * xp - B2 * yp;
            
            //intersection point of line 1 and line 2
            // x = ((-C1)*B2 - (-C2)*B1) / (A1*B2 - A2*B1)
            float ix = ((-C1)*B2 - (-C2)*B1) / (A1*B2 - A2*B1);
            // y = (A1*(-C2) - A2*(-C1)) / (A1*B2 - A2*B1)
            float iy = (A1*(-C2) - A2*(-C1)) / (A1*B2 - A2*B1);
            
            if ((MIN(x1, x2) <= ix <= MAX(x1, x2)) && (MIN(y1, y2) <= iy <= MAX(y1, y2))) {
                //situation when a projection of user's location point onto a line determined by two consecutive route points finds itself is placed on a segment between these two points
                
                //count distance between user's location and route
                CLLocation *intersectionLocation = [[CLLocation alloc] initWithLatitude:ix longitude:iy];
                CLLocationDistance distance = [intersectionLocation distanceFromLocation:usersLocation];
                if (distance < [[sharedInstance radius] doubleValue]) {
                    result = YES; //is in range
                }
            } else {
                //in case when a projection is not placed between these points count distance between user's location and these points
                CLLocation *location1 = [[CLLocation alloc] initWithLatitude:x1 longitude:y1];
                CLLocation *location2 = [[CLLocation alloc] initWithLatitude:x2 longitude:y2];
                CLLocationDistance distance1 = [location1 distanceFromLocation:usersLocation];
                CLLocationDistance distance2 = [location2 distanceFromLocation:usersLocation];
                if (distance1 < [[sharedInstance radius] doubleValue] || distance2 < [[sharedInstance radius] doubleValue]) {
                    result = YES; //is in range
                }
            }
        }
        return result;
    } else {
        //if no route is set always return YES
        return YES;
    }
}

- (NSString*)getEmergencyWithLocation:(CLLocationCoordinate2D) location {
    return [NSString stringWithFormat:@"EMG;%@;%f;%f\n", phoneNumber, location.latitude, location.longitude];
}

- (NSString*)getHiWithLocation:(CLLocationCoordinate2D) location {
    return [NSString stringWithFormat:@"HI;%@;%@;%f;%f\n", phoneNumber, emergencyPhoneNumber, location.latitude, location.longitude];
}

- (NSString*)getLocationMessage:(CLLocationCoordinate2D) location {
    return [NSString stringWithFormat:@"LOC;%@;%f;%f\n", phoneNumber, location.latitude, location.longitude];
}

- (NSString*)getEmergencyWithLastLocation {
    return [NSString stringWithFormat:@"EMG;%@;%f;%f\n", phoneNumber, [sharedInstance lastLocation].latitude, [sharedInstance lastLocation].longitude];
}

- (NSString*)getHiWithLastLocation {
    return [NSString stringWithFormat:@"HI;%@;%@;%f;%f\n", phoneNumber, emergencyPhoneNumber, [sharedInstance lastLocation].latitude, [sharedInstance lastLocation].longitude];
}

- (NSString*)getLastLocationMessage {
    return [NSString stringWithFormat:@"LOC;%@;%f;%f\n", phoneNumber, [sharedInstance lastLocation].latitude, [sharedInstance lastLocation].longitude];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // not used
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // not used
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    // not used
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    // application will not receive data from server hence there is nothing to do here
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    [sharedInstance setIsConnected:NO];
}


////działanie po wysłaniu SMSa
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//{
//    switch (result) {
//        case MessageComposeResultCancelled:
//            NSLog(@"Cancelled");
//            break;
//        case MessageComposeResultFailed: {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"SMS could not be sent" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            break;}
//        case MessageComposeResultSent:
//            break;
//        default:
//            break;
//    }
//}

-(void) addObserver:(id <Observer>) observer {
    if (![sharedInstance observers]) {
        [sharedInstance setObservers:[[NSMutableArray alloc] init]];
    }
    if (![[sharedInstance observers] containsObject:observer]) {
        [[sharedInstance observers] addObject:observer];
    }
}

-(void) removeObserver:(id <Observer>) observer {
    if ([[sharedInstance observers] containsObject:observer]) {
        [[sharedInstance observers] removeObject:observer];
    }
}

-(void) notifyObserversSms {
    for (id <Observer> observer in [sharedInstance observers]) {
        [observer notifySms];
    }
}
-(void) notifyObserversRoute {
    for (id <Observer> observer in [sharedInstance observers]) {
        [observer notifyRoute];
    }
}

@end
