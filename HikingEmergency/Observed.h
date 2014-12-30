//
//  Observed.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 29.12.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observer.h"

@protocol Observed <NSObject>

@required

-(void) addObserver:(id <Observer>) observer;
-(void) removeObserver:(id <Observer>) observer;
-(void) notifyObserversSms;
-(void) notifyObserversRoute;

@end
