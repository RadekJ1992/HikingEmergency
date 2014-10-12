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
    
    //wyświetlenie pinezki w miejcu wydarzenia
    for (MapPin *pin in [route getRoutePoints]) {
        [mapView addAnnotation:pin];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
