//
//  ATAnnotation.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ATAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
