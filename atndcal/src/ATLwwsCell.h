//
//  ATLwwsCell.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATEventTextCell.h"

@interface ATLwwsCell : ATEventTextCell {
  @private
    UIImageView *_iconImageView;
    UILabel *_pubDateLabel;
}
@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *pubDateLabel;

+ (CGFloat)heightCellOfLabelText:(NSString *)text truncate:(BOOL)truncate;

@end
