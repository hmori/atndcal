//
//  ATEventTextCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventTextCell.h"

#define xInsetTextCellForField 8.0f
#define yInsetTextCellForField 13.0f
#define widthTextCellForField 298.0f

#define heightTextCellForShort 132.0f
#define numberOfLinesForShort 6


@implementation ATEventTextCell
@synthesize truncate = _truncate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _field.backgroundColor = [UIColor clearColor];
        _field.numberOfLines = INT_MAX;
        _field.font = [UIFont systemFontOfSize:14.0f];
        
        self.label.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectZero;
	
	CGRect r = CGRectInset(self.contentView.bounds, xInsetTextCellForField, yInsetTextCellForField);
    r.size.height = CGFLOAT_MAX;
    r = [_field textRectForBounds:r limitedToNumberOfLines:_field.numberOfLines];
	_field.frame = r;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - setter

- (void)setTruncate:(BOOL)truncate {
    LOG_CURRENT_METHOD;
    _truncate = truncate;
    
    if (truncate) {
        _field.numberOfLines = numberOfLinesForShort;
    } else {
        _field.numberOfLines = INT_MAX;
    }
}

#pragma mark - Public

+ (CGFloat)heightCellOfLabelText:(NSString *)text truncate:(BOOL)truncate {
    POOL_START;

    CGFloat height;
    if (truncate) {
        height = heightTextCellForShort;
    } else {
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.text = text;
        label.numberOfLines = INT_MAX;
        label.font = [UIFont systemFontOfSize:14.0f];
        CGRect r = [label textRectForBounds:CGRectMake(0, 0, widthTextCellForField-(xInsetTextCellForField*2), CGFLOAT_MAX) 
                     limitedToNumberOfLines:INT_MAX];
        height = r.size.height + (yInsetTextCellForField*2);
    }
    
    POOL_END;
    return height;
}

+ (void)setOptionWithField:(UILabel *)label {
    label.numberOfLines = INT_MAX;
    label.font = [UIFont systemFontOfSize:14.0f];
}

@end
