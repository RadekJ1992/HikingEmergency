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

@property (nonatomic, retain) NSString* routeName;
@property (nonatomic, retain) NSMutableArray* routePoints;

-(id)initWithRouteName:(NSString*) name andRoutePoints:(NSArray*) points;

-(NSMutableArray*) getRoutePoints;

-(NSString*) getRouteName;

@end
