//
//  NavigateViewController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "NavigateViewController.h"
#import "WarningViewController.h"
#import "DBManager.h"
#import "LocationsController.h"

@interface NavigateViewController ()
@end

@implementation NavigateViewController
@synthesize isCurrentlyStationary;
@synthesize route;
@synthesize mapView;
@synthesize polyline;
@synthesize lineView;
@synthesize motionActivityManager;
@synthesize timer;
@synthesize routeAlert;
@synthesize smsAlert;
@synthesize isSOS;

/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"warning"]) {
        if (route) {
            WarningViewController *wVC = [segue destinationViewController];
            wVC.route = route;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    isCurrentlyStationary = false;
    [[self mapView] setDelegate:self];
    [super viewDidLoad];
    [[LocationsController getSharedInstance] addObserver:self];
    if ([[LocationsController getSharedInstance] isNavigating]) {
        [[self StartStopButton] setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [[self StartStopButton] setTitle:@"Start" forState:UIControlStateNormal];
    }
    self.motionActivityManager=[[CMMotionActivityManager alloc]init];
    //wyświetlenie mapy
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[[route getRoutePoints] firstObject] coordinate], 1000, 1000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;
    [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity)
     {
         if (activity.stationary == YES) {
             if (!isCurrentlyStationary) {
                 isCurrentlyStationary = YES;
                 NSTimer *countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 600 //10 minut bez ruchu
                                                                            target:self
                                                                          selector:@selector(triggerAlarm:)
                                                                          userInfo:nil
                                                                           repeats:NO];
                 timer = countdownTimer;
                 NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
                 NSLog(@"Timer Started! No motion detected!");
                 [runLoop addTimer:countdownTimer forMode:NSDefaultRunLoopMode];
             }
         } else {
             isCurrentlyStationary = NO;
             NSLog(@"Timer Stopped! Motion detected");
             [timer invalidate];
             timer = nil;
         }
     }];
    if ([self isSOS]) {
        [[LocationsController getSharedInstance] sendEmergencyWithLastKnownLocation];
    }
    [self drawLines:self];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return self.lineView;
}

- (void)drawLineSubroutine {
    
    [self.mapView removeOverlay:self.polyline];

    //draw route
    for (MapPin *pin in [route getRoutePoints]) {
        [mapView addAnnotation:pin];
    }
    
    CLLocationCoordinate2D coordinateArray[[[route getRoutePoints] count]];
    
    for (int i = 0; i < [[route getRoutePoints] count]; i++) {
        CLLocationCoordinate2D loc = [((MapPin*)[[route getRoutePoints] objectAtIndex:i]) coordinate];
        coordinateArray[i] = loc;
    }
    
    MKPolyline *newpolyline = [MKPolyline polylineWithCoordinates:coordinateArray count:[[route getRoutePoints] count]];
    [self.mapView addOverlay:newpolyline];
    self.polyline = newpolyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 5;
}

- (void) triggerAlarm:(NSTimer *)timer {
    [[self timer] invalidate];
    self.timer = nil;
    [self performSegueWithIdentifier:@"warning" sender:self];
}

- (IBAction)drawLines:(id)sender {
    
    // HACK: for some reason this only updates the map view every other time
    // and because life is too frigging short, let's just call it TWICE
    
    [self drawLineSubroutine];
    [self drawLineSubroutine];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)StartStopButtonPressed:(id)sender {
    if ([[LocationsController getSharedInstance] isNavigating]) {
        [[self StartStopButton] setTitle:@"Start" forState:UIControlStateNormal];
        [[LocationsController getSharedInstance] setIsNavigating:NO];
        
    } else {
        [[self StartStopButton] setTitle:@"Stop" forState:UIControlStateNormal];
        [[LocationsController getSharedInstance] setRoute:[self route]];
        [[LocationsController getSharedInstance] setIsNavigating:YES];
    }
}

- (IBAction)SOSClicked:(id)sender {
    [[LocationsController getSharedInstance] sendEmergencyWithLastKnownLocation];
    [self sendSMSWithMessage:[[LocationsController getSharedInstance] getEmergencyWithLastLocation]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == [self routeAlert]) {
        if (buttonIndex == 0) {
            NSLog(@"OK Tapped.");
        }
        else if (buttonIndex == 1) {
            NSLog(@"Help Me! Tapped. Sending Emergency!");
            [[LocationsController getSharedInstance] sendEmergencyWithLastKnownLocation];
            [self SOSClicked:self];
        }
    }
    if (alertView == [self smsAlert]) {
        if (buttonIndex == 0) {
            NSLog(@"No Tapped.");
        }
        else if (buttonIndex == 1) {
            NSLog(@"Yes Tapped, sending SMS");
            [self sendSMSWithLastLocation];
        }
    }
}

-(void) notifySms {
    [self setSmsAlert:[[UIAlertView alloc] initWithTitle:@"Can't connect using TCP connection"
                                                           message:@"Do you want to send location via SMS?"
                                                          delegate:self
                                                 cancelButtonTitle:@"No"
                                                 otherButtonTitles:@"Yes" ,nil]];
    [[self smsAlert] show];

}

-(void) notifyRoute {
    [self setRouteAlert:[[UIAlertView alloc] initWithTitle:@"Get back on track!"
                                                   message:@"You are too far away from route"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:@"Help Me!"
                                                          ,nil]];
   [[self routeAlert] show];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[LocationsController getSharedInstance] removeObserver:self];
}

-(void) sendSMSWithMessage: (NSString*) message {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = message;
        NSMutableArray* contactsPhoneNumbers = [[NSMutableArray alloc] init];
        [contactsPhoneNumbers addObject:[[LocationsController getSharedInstance] serverPhoneNumber]];
        controller.recipients = contactsPhoneNumbers;
        [controller setMessageComposeDelegate: self];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        NSLog(@"Can't send SMS");
    }
}

-(void) sendSMSWithLastLocation {
    [self sendSMSWithMessage:[[LocationsController getSharedInstance] getLastLocationMessage]];
}

//działanie po wysłaniu SMSa
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"SMS could not be sent" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;}
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
