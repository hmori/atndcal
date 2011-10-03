//
//  ATEventLabelTextCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

//#define widthLabel 45.0f

@interface ATEventLabelTextCell : TKLabelFieldCell {
    CGFloat _widthLabel;
}
@property CGFloat widthLabel;

@end
