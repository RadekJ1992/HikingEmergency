    //
//  CreateRouteViewController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "CreateRouteViewController.h"
#import "DBManager.h"
#import "LocationsController.h"

@interface CreateRouteViewController ()

@end

@implementation CreateRouteViewController

@synthesize mapView;
@synthesize routeNameField;
@synthesize route;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [routeNameField setDelegate:self];
    //obsługa wciśnięcia i przytrzymania palca na mapie - dodanie pozycji trasy
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    //wyświetlenie domyślnej lokalizacji - centrum Warszawy
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    [[LocationsController getSharedInstance] setCurrentViewController:self];
    region.center.latitude = 52.2296756;
    region.center.longitude = 21.0122287;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [mapView setRegion:region animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!route) {
            route = [[Route alloc] init];
        }
        MapPin* pin = [[MapPin alloc] init];
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
        region.center.latitude = locCoord.latitude;
        region.center.longitude = locCoord.longitude;
        region.span.longitudeDelta = 0.01f;
        region.span.latitudeDelta = 0.01f;
        pin.coordinate = region.center;
        //ustaw "Title" jako indeks
        [pin setTitle: [NSString stringWithFormat:@"%lu", (unsigned long)[[route getRoutePoints] count] ]];
        [pin setIndex: [[route getRoutePoints] count]];
        [[route getRoutePoints] addObject:pin];
        [self.mapView addAnnotation:pin];
    }
}

- (IBAction)addRoute:(id)sender {
    if ([[routeNameField text] length] != 0) {
        [route setRouteName: [routeNameField text]];
    } else {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormat stringFromDate:date];
        [route setRouteName: dateString];
    }
    if ([[route getRoutePoints] count] != 0) {
        [[DBManager getSharedInstance] createNewRoute:route];
    }
}
@end