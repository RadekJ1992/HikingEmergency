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
  //  AVAudioPlayer *audioPlayer;
}

@end

@implementation WarningViewController

@synthesize timeLeft;
@synthesize timer;
@synthesize route;
@synthesize audioPlayer;

int timeValue = 60;
/**
 obsługa przekazywania obiektów między viewControllerami
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imOk"]) {
        if (route) {
            NavigateViewController *nVC = [segue destinationViewController];
            nVC.route = route;
        }
    }
    if ([segue.identifier isEqualToString:@"SOS"]) {
        if (route) {
            NavigateViewController *nVC = [segue destinationViewController];
            nVC.route = route;
            nVC.isSOS = YES;
        }
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [NSString stringWithFormat:@"%@/alarm.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self setAudioPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil]];
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
    [[self audioPlayer] stop];
    [[self audioPlayer] play];
    if (timeValue == 0 ) {
        //[[LocationsController getSharedInstance] sendEmergencyWithLastKnownLocation];
        [[self timer] invalidate];
        [self setTimer: nil];
        [self SOSclicked:self];
    } else {
        [timeLeft setText:[NSString stringWithFormat:@"%d", timeValue]];
    }
}

- (IBAction)SOSclicked:(id)sender {
    [[self audioPlayer] pause];
    [[self audioPlayer] stop];
    [[self timer] invalidate];
    [self setTimer: nil];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"SOS" sender: nil];
}

- (IBAction)ImOKclicked:(id)sender {
    [[self audioPlayer] pause];
    [[self audioPlayer] stop];
    [[self timer] invalidate];
    [self setTimer: nil];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"imOk" sender: nil];
}
@end
