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

-(NSMutableArray*) getRoutePoints {
    return routePoints;
}

-(NSString*) getRouteName {
    return routeName;
}

-(id)initWithRouteName:(NSString*) name andRoutePoints:(NSMutableArray*) points{
    self = [super init];
    if (self) {
        self.routeName = name;
        self.routePoints = points;
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        self.routeName = [[NSString alloc] init];
        self.routePoints = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
