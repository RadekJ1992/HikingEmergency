//
//  NavigateViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Route.h"
#import "MapPin.h"

@interface NavigateViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Route* route;
@property (nonatomic, strong) MKPolylineView *lineView;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic,strong) CMMotionActivityManager *motionActivityManager;
@property (weak) NSTimer *timer;
@property (nonatomic) BOOL isCurrentlyStationary;


@end