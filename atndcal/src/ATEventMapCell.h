#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ATEventMapCell : UITableViewCell {
    MKMapView *_mapView;
    CLLocationCoordinate2D _location;
    
}
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D location;

+ (CGFloat)heightCell;

@end
