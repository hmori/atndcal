//
//  ATEventOutlineGroupedCell.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventOutlineGroupedCell.h"

@interface ATEventOutlineGroupedCell ()
- (void)initATEventOutlineGroupedCell;
@end

@implementation ATEventOutlineGroupedCell
@synthesize eventOutline = _eventOutline;

#define heightEventOutlineGroupedCell 57.0f

static UIFont *_titleFont = nil;
static UIFont *_detailFont = nil;
static UIColor *_titleColor = nil;
static UIColor *_detailColor = nil;
static UIColor *_disableColor = nil;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initATEventOutlineGroupedCell];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = _titleFont;
        _titleLabel.text = @"タイトルタイトルタイトルタイトルタイトルタイトルタイトルタイトル";
        [self.contentView addSubview:_titleLabel];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _detailColor = _detailColor;
        _dateLabel.textColor = _detailColor;
        _dateLabel.font = _detailFont;
        _dateLabel.text = @"10/10 8:00 〜 10:00";
        [self.contentView addSubview:_dateLabel];

        _placeLabel = [[UILabel alloc] init];
        _placeLabel.backgroundColor = [UIColor clearColor];
        _placeLabel.font = _detailFont;
        _placeLabel.textColor = _detailColor;
        _placeLabel.text = @"七北田公園";
        [self.contentView addSubview:_placeLabel];

    }
    return self;
}

- (void)initATEventOutlineGroupedCell {
    if (!_titleFont) {
        _titleFont = [[UIFont boldSystemFontOfSize:14] retain];
    }
    if (!_detailFont) {
        _detailFont = [[UIFont boldSystemFontOfSize:11] retain];
    }
    if (!_titleColor) {
        _titleColor = [[UIColor blackColor] retain];
    }
    if (!_detailColor) {
        _detailColor = [HEXCOLOR(0x2470D8FF) retain];
    }
    if (!_disableColor) {
        _disableColor = [[UIColor lightGrayColor] retain];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = CGRectInset(self.contentView.bounds, 8.0f, 6.0f);
    
    r.size.height = 17.0f;
    _titleLabel.frame = r;
    r.origin.y += 16.0f;
    _dateLabel.frame = r;
    r.origin.y += 14.0f;
    _placeLabel.frame = r;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _titleLabel.textColor = selected ? [UIColor whiteColor] : _titleColor;
    _dateLabel.textColor = selected ? [UIColor whiteColor] : _detailColor;
    _placeLabel.textColor = selected ? [UIColor whiteColor] : _detailColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
    _titleLabel.textColor = highlighted ? [UIColor whiteColor] : _titleColor;
    _dateLabel.textColor = highlighted ? [UIColor whiteColor] : _detailColor;
    _placeLabel.textColor = highlighted ? [UIColor whiteColor] : _detailColor;
}

- (void)dealloc {
    [_eventOutline release];
    
    [_titleLabel release];
    [_dateLabel release];
    [_placeLabel release];
    [super dealloc];
}


#pragma mark - setter

- (void)setEventOutline:(ATEventOutline *)eventOutline {
    if (_eventOutline != eventOutline) {
        [_eventOutline release];
        _eventOutline = [eventOutline retain];
        
        _titleLabel.text = eventOutline.title;
        _dateLabel.text = eventOutline.date;
        _placeLabel.text = eventOutline.place;
        
        if ([eventOutline isOver]) {
            _titleLabel.textColor = _disableColor;
            _dateLabel.textColor = _disableColor;
            _placeLabel.textColor = _disableColor;
        } else {
            _titleLabel.textColor = _titleColor;
            _dateLabel.textColor = _detailColor;
            _placeLabel.textColor = _detailColor;
        }
        
        [self setNeedsLayout];
    }
}

#pragma mark - Public 

+ (CGFloat)heightCell {
    return heightEventOutlineGroupedCell;
}


@end
