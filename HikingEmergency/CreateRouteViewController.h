//
//  CreateRouteViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "Route.h"
#import <CoreLocation/CoreLocation.h>
/**
 ViewController obsługujący stworzenie trasy
 */
@interface CreateRouteViewController : UIViewController <UISearchBarDelegate>

//okienko z mapą
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
//TextField służący do wprowadzenia nazwy trasy
@property (weak, nonatomic) IBOutlet UITextField *routeNameField;
//obiekt reprezentujący trasę
@property (strong, nonatomic) Route* route;
//po wciśnięciu przycisku "Done"
- (IBAction)addRoute:(id)sender;

@end
