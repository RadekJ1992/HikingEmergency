//
//  LocationsController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 15.11.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/**
 Singleton obsługujący wysyłanie informacji o lokalizacji
 */
@interface LocationsController : NSObject

@property bool isFirstLocation;
@property (atomic, assign) CLLocationCoordinate2D lastLocation;
@property (weak) NSTimer* timer;

+(LocationsController*)getSharedInstance;

- (void)addLocation:(CLLocationCoordinate2D) location;

- (void)sendEmergencyWithLocation:(CLLocationCoordinate2D) location;

- (void)sendEmergencyWithLastKnownLocation;
@end
