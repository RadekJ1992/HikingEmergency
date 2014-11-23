//
//  LocationsController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 15.11.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "LocationsController.h"
#import "DBManager.h"
#import "TCPManager.h"
#import <MapKit/MapKit.h>

@implementation LocationsController

static LocationsController *sharedInstance = nil;

@synthesize isFirstLocation;
@synthesize lastLocation;
@synthesize timer;
@synthesize route;
@synthesize radius;

+(LocationsController*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance setIsFirstLocation:YES];
        //get safety radius from settings
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [sharedInstance setRadius: [formatter numberFromString: [standardUserDefaults objectForKey:@"radius"]]];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                          target:self
                                                        selector:@selector(sendLocation)
                                                        userInfo:sharedInstance
                                                         repeats:YES];
        [sharedInstance setTimer: timer];
    }
    return sharedInstance;
}

- (void)addLocation:(CLLocationCoordinate2D) location {
    lastLocation = location;
}

+(void) sendLocation {
    [[DBManager getSharedInstance] insertUserLocation:[sharedInstance lastLocation]];
    if (![sharedInstance isInRange:[sharedInstance lastLocation]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get back on track!"
                                                        message:@"You are too far away from route"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Help Me!" ,nil];
        [alert show];
    }
    if ([sharedInstance isFirstLocation]) {
        [[TCPManager getSharedInstance] sendHiWithLocation:[sharedInstance lastLocation]];
        [sharedInstance setIsFirstLocation:NO];
    } else {
        [[TCPManager getSharedInstance] sendLocation:[sharedInstance lastLocation]];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"OK Tapped.");
    }
    else if (buttonIndex == 1) {
        NSLog(@"Help Me! Tapped. Sending Emergency!");
        [sharedInstance sendEmergencyWithLastKnownLocation];
    }
}

- (void)sendEmergencyWithLocation:(CLLocationCoordinate2D) location {
    lastLocation = location;
    [[DBManager getSharedInstance] insertUserLocation:location];
    [[TCPManager getSharedInstance] sendEmergencyWithLocation:location];
}

- (void)sendEmergencyWithLastKnownLocation {
    [[TCPManager getSharedInstance] sendEmergencyWithLocation: [sharedInstance lastLocation]];
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

@end
