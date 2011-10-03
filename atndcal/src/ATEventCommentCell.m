//
//  ATEventCommentCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventCommentCell.h"

#define xInsetCommentCellForField 8.0f
#define yInsetCommentCellForField 13.0f
#define widthCommentCellForField 298.0f

#define adjustFieldY 38.0f

@implementation ATEventCommentCell

@synthesize pubDateLabel = _pubDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        POOL_START;
        self.label.font = [UIFont boldSystemFontOfSize:16];
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.textColor = [UIColor blackColor];
        self.pubDateLabel = [[[UILabel alloc] init] autorelease];
        _pubDateLabel.font = [UIFont systemFontOfSize:13];
        _pubDateLabel.textColor = HEXCOLOR(0x44608CFF);
        [self.contentView addSubview:_pubDateLabel];
        POOL_END;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect lr = CGRectInset(self.contentView.bounds, xInsetCommentCellForField, yInsetCommentCellForField);
    lr.size.height = self.label.font.pointSize + 2.0f;
    self.label.frame = lr;
    
    lr.origin.y += lr.size.height + 2.0f;
    lr.size.height = _pubDateLabel.font.pointSize + 2.0f;
    _pubDateLabel.frame = lr;
    
	CGRect r = CGRectInset(self.contentView.bounds, xInsetCommentCellForField, yInsetCommentCellForField);
    r.origin.y += adjustFieldY;
    r.size.height = CGFLOAT_MAX;
    r = [_field textRectForBounds:r limitedToNumberOfLines:INT_MAX];
	_field.frame = r;
}

- (void)dealloc {
    [_pubDateLabel release];
    [super dealloc];
}

#pragma mark - Public

@end
