//
//  NavigateViewController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "NavigateViewController.h"
#import "DBManager.h"

@interface NavigateViewController ()
@end

@implementation NavigateViewController
@synthesize route;
@synthesize mapView;
@synthesize routeLine;
@synthesize routeLineView;

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
    
    //wyświetlenie mapy
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[[route getRoutePoints] firstObject] coordinate], 1000, 1000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;
    
    for (MapPin *pin in [route getRoutePoints]) {
        [mapView addAnnotation:pin];
    }
    int routeCount = (int)[[route getRoutePoints] count];
    CLLocationCoordinate2D *coordinateArray = malloc(sizeof(CLLocationCoordinate2D) * routeCount);
    for (int i = 0; i < routeCount; i++) {
        CLLocationCoordinate2D loc = [((MapPin*)[[route getRoutePoints] objectAtIndex:i]) coordinate];
        coordinateArray[i] = loc;
    }
    
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:[[route getRoutePoints] count]];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView addOverlay:self.routeLine];
    });
   // [self.mapView addOverlay:self.routeLine];
    free(coordinateArray);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        aView.lineWidth = 10;
        return aView;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
