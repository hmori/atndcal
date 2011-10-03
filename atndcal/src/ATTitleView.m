//
//  ATTitleView.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATTitleView.h"

#import "NSString+ATCategory.h"

@interface ATTitleView ()
- (void)initATTitleView;
@end

@implementation ATTitleView

@synthesize titleLabel = _titleLabel;

- (id)init {
    if ((self = [super init])) {
        [self initATTitleView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initATTitleView];
    }
    return self;
}

- (void)initATTitleView {
    POOL_START;
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowColor = [UIColor darkGrayColor];
    _titleLabel.shadowOffset = CGSizeMake(0,-1);
    _titleLabel.numberOfLines = 2;
    [self addSubview:_titleLabel];
    POOL_END;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    LOG_CURRENT_METHOD;
    
    self.frame = newSuperview.bounds;
}

- (void)layoutSubviews {
    LOG_CURRENT_METHOD;
    [super layoutSubviews];
    LOG_FRAME(self.bounds);

    _titleLabel.frame = CGRectInset(self.bounds, 10, 4);
    CGFloat fontSize = [_titleLabel.text fontSizeWithFont:[UIFont boldSystemFontOfSize:21] 
                            constrainedToSize:_titleLabel.frame.size];
    if (fontSize < 12.0f) {
        fontSize = 12.0f;
    }
    _titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
}

- (void)dealloc {
    [_titleLabel release];
    [super dealloc];
}

#pragma mark - Public

- (void)setTitle:(NSString *)text {
    LOG_CURRENT_METHOD;
    _titleLabel.text = text;
    [self setNeedsLayout];
}

@end
