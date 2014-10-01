#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
/**
 Obiekt reprezentujący pozycję na mapie (protokół MKAnnotation pozwala na wyświetlenie jej na mapie)
 */
@interface MapPin : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSDate *date;

@end
