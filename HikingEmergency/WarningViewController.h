//
//  WarningViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Route.h"
#import "NavigateViewController.h"

@interface WarningViewController : UIViewController

@property (weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITextField *timeLeft;
@property (strong) AVAudioPlayer *audioPlayer;
/**
 wybrana trasa
 */
@property (strong, nonatomic) Route* route;
- (IBAction)SOSclicked:(id)sender;
- (IBAction)ImOKclicked:(id)sender;

@end
