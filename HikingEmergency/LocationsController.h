//
//  LocationsController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 15.11.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DBManager.h"
#import "Route.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "AppDelegate.h"
#import "Observed.h"
/**
 Singleton obsługujący wysyłanie informacji o lokalizacji
 */
@interface LocationsController : NSObject <Observed>

@property bool isFirstLocation;
@property bool isConnected;
@property bool isSMSEnabled;
@property (atomic, assign) CLLocationCoordinate2D lastLocation;
@property (weak) NSTimer* timer;
@property (weak) NSTimer* smsTimer;
@property (strong, nonatomic) GCDAsyncUdpSocket* udpSocket;
@property (strong, nonatomic) GCDAsyncSocket* tcpSocket;
@property (strong, nonatomic) Route* route;
@property (weak, nonatomic) NSNumber* radius;
@property (weak, nonatomic) NSString* serverIP;
@property (weak, nonatomic) NSString* serverTCPPort;
@property (weak, nonatomic) NSString* serverUDPPort;
@property (weak, nonatomic) NSString* phoneNumber;
@property (weak, nonatomic) NSString* emergencyPhoneNumber;
//@property (weak, nonatomic) UIAlertView* routeAlert;
//@property (weak, nonatomic) UIAlertView* smsAlert;
@property (strong, nonatomic) NSMutableArray* observers;

@property (nonatomic) BOOL isNavigating;

+(LocationsController*)getSharedInstance;

- (void)addLocation:(CLLocationCoordinate2D) location;

- (void)sendEmergencyWithLastKnownLocation;

//-(void) sendSMSWithLastLocation;

- (NSString*)getLastLocationMessage;
@end
