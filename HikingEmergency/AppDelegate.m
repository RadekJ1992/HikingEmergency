//
//  AppDelegate.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 29.09.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationsController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //pobranie ustawień z SettingsBundle
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * ip = [standardUserDefaults objectForKey:@"serverIP"];
    NSString * port = [standardUserDefaults objectForKey:@"serverPort"];
    NSString *phoneNumber = (NSString*)[[NSUserDefaults standardUserDefaults] valueForKey:@"emergencyPhoneNumber"];
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * radius = [formatter numberFromString: [standardUserDefaults objectForKey:@"radius"]];
    if (!ip || !port || !phoneNumber || !radius) {
        [self registerDefaultsFromSettingsBundle];
    }
    
    //uruchomienie locationManagera w celu pobierania lokalizacji GPS
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 10;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //wyłączenie usług lokalizacji
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager stopUpdatingLocation];
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
}



//wywoływane po zaktualizowaniu lokalizacji - wprowadzenie jej do bazy danych i wysłanie informacji na serwer
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"locationUpdate %f, %f" ,[locations[0] coordinate].latitude, [locations[0] coordinate].longitude);
    [[LocationsController getSharedInstance] addLocation: [locations[0] coordinate]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        // Stop normal location updates and start significant location change updates for battery efficiency.
        [locationManager stopUpdatingLocation];
        [locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        // Stop significant location updates and start normal location updates again since the app is in the forefront.
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
}



@end
