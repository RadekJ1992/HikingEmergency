//
//  MainMenuViewController.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 02.01.2015.
//  Copyright (c) 2015 Radosław Jarzynka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MainMenuViewController : UIViewController <MFMessageComposeViewControllerDelegate>

- (IBAction)SOSClicked:(id)sender;

@end
