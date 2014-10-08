//
//  MapPin.h
//  HikingEmergency
//
//  Created by Radosław Jarzynka on 06.10.2014.
//  Copyright (c) 2014 Radosław Jarzynka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
/**
 Obiekt reprezentujący pozycję na mapie (protokół MKAnnotation pozwala na wyświetlenie jej na mapie)
 */
@interface MapPin : NSObject <MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSDate *date;

@end
