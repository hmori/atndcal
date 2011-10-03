//
//  ATEventCommentCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATEventTextCell.h"


@interface ATEventCommentCell : ATEventTextCell {
    UILabel *_pubDateLabel;
}
@property (nonatomic, retain) UILabel *pubDateLabel;

@end
