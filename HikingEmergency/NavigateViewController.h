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
#import <MessageUI/MessageUI.h>
#import "Route.h"
#import "MapPin.h"
#import "Observer.h"

@interface NavigateViewController : UIViewController <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, MKMapViewDelegate, Observer>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Route* route;
@property (nonatomic, strong) MKPolylineView *lineView;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic,strong) CMMotionActivityManager *motionActivityManager;
@property (weak) NSTimer *timer;
@property (nonatomic) BOOL isCurrentlyStationary;
@property (nonatomic) BOOL isSOS;
@property (weak, nonatomic) IBOutlet UIButton *StartStopButton;
@property (strong, nonatomic) UIAlertView* routeAlert;
@property (strong, nonatomic) UIAlertView* smsAlert;

- (IBAction)StartStopButtonPressed:(id)sender;
- (IBAction)SOSClicked:(id)sender;

@end