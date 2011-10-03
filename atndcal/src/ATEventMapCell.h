//
//  ATEventMapCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ATEventMapCell : UITableViewCell {
    MKMapView *_mapView;
    CLLocationCoordinate2D _location;
    
}
@property (nonatomic, retain) MKMapView *mapView;
@property CLLocationCoordinate2D location;

+ (CGFloat)heightCell;

@end
