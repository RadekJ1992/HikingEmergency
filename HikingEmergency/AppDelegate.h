//
//  AppDelegate.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 29.09.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;


- (void)registerDefaultsFromSettingsBundle;

@end

