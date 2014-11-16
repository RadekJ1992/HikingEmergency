//
//  WarningViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 11.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WarningViewController : UIViewController

@property (weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITextField *timeLeft;

@end
