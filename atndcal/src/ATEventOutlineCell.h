//
//  ATEventTableViewCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATEventOutline.h"

@interface ATEventOutlineCell : TKIndicatorCell {
    ATEventOutline *_eventOutline;
}
@property (nonatomic, retain) ATEventOutline *eventOutline;

@end
