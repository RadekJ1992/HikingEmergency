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

@implementation LocationsController

static LocationsController *sharedInstance = nil;

@synthesize isFirstLocation;
@synthesize lastLocation;
@synthesize timer;

+(LocationsController*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance setIsFirstLocation:YES];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                          target:self selector:@selector(sendLocation)
                                                        userInfo:sharedInstance repeats:YES];
        [sharedInstance setTimer: timer];
    }
    return sharedInstance;
}

- (void)addLocation:(CLLocationCoordinate2D) location {
    lastLocation = location;
}

+(void) sendLocation {
    [[DBManager getSharedInstance] insertUserLocation:[sharedInstance lastLocation]];
    if ([sharedInstance isFirstLocation]) {
        [[TCPManager getSharedInstance] sendHiWithLocation:[sharedInstance lastLocation]];
        [sharedInstance setIsFirstLocation:NO];
    } else {
        [[TCPManager getSharedInstance] sendLocation:[sharedInstance lastLocation]];
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
@end
