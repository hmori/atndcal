//
//  ATEventLabelTextCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventLabelTextCell.h"


@implementation ATEventLabelTextCell
@synthesize widthLabel = _widthLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.label.textAlignment = UITextAlignmentLeft;
        self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

        self.field.numberOfLines = INT_MAX;
        self.field.font = [UIFont systemFontOfSize:14.0f];
        self.field.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

        _widthLabel = 45.0f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
    CGRect r = CGRectInset(self.contentView.bounds, 8, 8);
	r.size.width = _widthLabel;
	_label.frame = r;

	
    r = CGRectInset(self.contentView.bounds, 8, 8);
	r.origin.x += self.label.frame.size.width + 6;
	r.size.width -= self.label.frame.size.width + 6;
	_field.frame = r;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [super dealloc];
}

@end
