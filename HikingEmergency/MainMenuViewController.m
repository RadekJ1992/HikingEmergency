//
//  MainMenuViewController.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 02.01.2015.
//  Copyright (c) 2015 Radosław Jarzynka. All rights reserved.
//

#import "MainMenuViewController.h"
#import "LocationsController.h"

@implementation MainMenuViewController

- (IBAction)SOSClicked:(id)sender {
    [[LocationsController getSharedInstance] sendEmergencyWithLastKnownLocation];
    [self sendSMSWithMessage:[[LocationsController getSharedInstance] getEmergencyWithLastLocation]];
}

-(void) sendSMSWithMessage: (NSString*) message {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = message;
        NSMutableArray* contactsPhoneNumbers = [[NSMutableArray alloc] init];
        [contactsPhoneNumbers addObject:[[LocationsController getSharedInstance] emergencyPhoneNumber]];
        controller.recipients = contactsPhoneNumbers;
        [controller setMessageComposeDelegate: self];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        NSLog(@"Can't send SMS");
    }
}

//działanie po wysłaniu SMSa
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"SMS could not be sent" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;}
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
