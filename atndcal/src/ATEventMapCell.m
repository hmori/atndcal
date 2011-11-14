#import "ATEventMapCell.h"
#import <QuartzCore/QuartzCore.h>

#import "ATAnnotation.h"


#define heightMapCell 132.0f

@implementation ATEventMapCell

@synthesize mapView = _mapView;
@synthesize location = _location;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        POOL_START;
        self.mapView = [[[MKMapView alloc] initWithFrame:self.contentView.bounds] autorelease];
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled = NO;
        _mapView.userInteractionEnabled = NO;
        [self.contentView addSubview:_mapView];
        POOL_END;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	_mapView.frame = CGRectInset(self.contentView.bounds, 0, 0);
    _mapView.layer.cornerRadius = 10.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [_mapView release];
    [super dealloc];
}

#pragma mark - setter

- (void)setLocation:(CLLocationCoordinate2D)coordinate {
    POOL_START;
    _location = coordinate;
    
    MKCoordinateRegion region;
    region.center = coordinate;
    
    ATAnnotation *annotation = [[[ATAnnotation alloc] init] autorelease];
    annotation.coordinate = coordinate;
    [_mapView addAnnotation:annotation];

    MKCoordinateSpan span;
    span.latitudeDelta = 0.0005f;
    span.longitudeDelta = 0.0005f;
    region.span = span;
    [_mapView setRegion:region animated:NO];
    
    [self setNeedsDisplay];
    
    POOL_END;
}

+ (CGFloat)heightCell {
    return heightMapCell;
}

@end
