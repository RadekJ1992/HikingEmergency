//
//  Route.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 08.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapPin.h"

@interface Route : NSObject

@property (nonatomic, assign) NSString* routeName;
@property (nonatomic, assign) NSArray* routePoints;

-(id)initWithRouteName:(NSString*) name andRoutePoints:(NSArray*) points;

-(NSArray*) getRoutePoints;

-(NSString*) getRouteName;

@end
