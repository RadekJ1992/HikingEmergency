//
//  Observer.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 29.12.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Observer <NSObject>

@required

-(void) notifySms;
-(void) notifyRoute;

@end
