//
//  WarningViewController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "WarningViewController.h"
#import "LocationsController.h"

@interface WarningViewController () {
    AVAudioPlayer *audioPlayer;
}

@end

@implementation WarningViewController

@synthesize timeLeft;
@synthesize timer;
@synthesize route;

int timeValue = 60;

if ([segue.identifier isEqualToString:@"imOk"]) {
    if (route) {
        NavigateViewController *nVC = [segue destinationViewController];
        nVC.route = route;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [NSString stringWithFormat:@"%@/alarm.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    NSTimer *countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(decreaseTimeLeft:)
                                                             userInfo:nil
                                                              repeats:YES];
    timer = countdownTimer;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [timeLeft setText:[NSString stringWithFormat:@"%d", timeValue]];
    [runLoop addTimer:countdownTimer forMode:NSDefaultRunLoopMode];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)decreaseTimeLeft:(NSTimer *)timer
{
    timeValue -= 1;
    [audioPlayer stop];
    [audioPlayer play];
    if (timeValue == 0 ) {
        [[LocationsController getSharedInstance] sendEmergencyWithLastKnownLocation];
        [[self timer] invalidate];
        [self setTimer: nil];
    } else {
        [timeLeft setText:[NSString stringWithFormat:@"%d", timeValue]];
    }
}

@end
