#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ATAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
