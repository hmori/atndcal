//
//  ATEventOutlineGroupedCell.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATEventOutline.h"

@interface ATEventOutlineGroupedCell : UITableViewCell {
    ATEventOutline *_eventOutline;
    
    UILabel *_titleLabel;
    UILabel *_dateLabel;
    UILabel *_placeLabel;
}
@property (nonatomic, retain) ATEventOutline *eventOutline;


+ (CGFloat)heightCell;

@end
