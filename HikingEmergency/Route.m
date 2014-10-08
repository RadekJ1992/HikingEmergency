//
//  Route.m
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 08.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import "Route.h"

@implementation Route

@synthesize routeName;
@synthesize routePoints;

-(NSArray*) getRoutePoints {
    return routePoints;
}

-(NSString*) getRouteName {
    return routeName;
}

-(id)initWithRouteName:(NSString*) name andRoutePoints:(NSArray*) points{
    self = [super init];
    if (self) {
        self.routeName = name;
        self.routePoints = points;
    }
    return self;
}

@end
