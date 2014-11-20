//
//  NavigateViewController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "NavigateViewController.h"
#import "WarningViewController.h"
#import "DBManager.h"

@interface NavigateViewController ()
@end

@implementation NavigateViewController
@synthesize isCurrentlyStationary;
@synthesize route;
@synthesize mapView;
@synthesize polyline;
@synthesize lineView;
@synthesize motionActivityManager;
@synthesize timer;

/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"warning"]) {
        if (route) {
            WarningViewController *wVC = [segue destinationViewController];
            wVC.route = route;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    isCurrentlyStationary = false;
    [[self mapView] setDelegate:self];
    [super viewDidLoad];
    self.motionActivityManager=[[CMMotionActivityManager alloc]init];
    //wyświetlenie mapy
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[[route getRoutePoints] firstObject] coordinate], 1000, 1000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;
    
    [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity)
     {
         if (activity.stationary == YES) {
             if (!isCurrentlyStationary) {
                 isCurrentlyStationary = YES;
                 NSTimer *countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 600 //10 minut bez ruchu
                                                                            target:self
                                                                          selector:@selector(triggerAlarm:)
                                                                          userInfo:nil
                                                                           repeats:NO];
                 timer = countdownTimer;
                 NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
                 NSLog(@"Timer Started! No motion detected!");
                 [runLoop addTimer:countdownTimer forMode:NSDefaultRunLoopMode];
             }
         } else {
             isCurrentlyStationary = NO;
             NSLog(@"Timer Stopped! Motion detected");
             [timer invalidate];
             timer = nil;
         }
     }];
    
    [self drawLines:self];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return self.lineView;
}

- (void)drawLineSubroutine {
    
    [self.mapView removeOverlay:self.polyline];

    //draw route
    for (MapPin *pin in [route getRoutePoints]) {
        [mapView addAnnotation:pin];
    }
    
    CLLocationCoordinate2D coordinateArray[[[route getRoutePoints] count]];
    
    for (int i = 0; i < [[route getRoutePoints] count]; i++) {
        CLLocationCoordinate2D loc = [((MapPin*)[[route getRoutePoints] objectAtIndex:i]) coordinate];
        coordinateArray[i] = loc;
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinateArray count:[[route getRoutePoints] count]];
    [self.mapView addOverlay:polyline];
    self.polyline = polyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 5;
}

- (void) triggerAlarm:(NSTimer *)timer {
    [[self timer] invalidate];
    self.timer = nil;
    [self performSegueWithIdentifier:@"warning" sender:self];
}

- (IBAction)drawLines:(id)sender {
    
    // HACK: for some reason this only updates the map view every other time
    // and because life is too frigging short, let's just call it TWICE
    
    [self drawLineSubroutine];
    [self drawLineSubroutine];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
