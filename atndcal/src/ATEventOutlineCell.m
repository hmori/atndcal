//
//  ATEventTableViewCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventOutlineCell.h"
#import "ATCommon.h"

@interface ATEventOutlineCell ()
- (void)initATEventOutlineCell;
@end

@implementation ATEventOutlineCell
@synthesize eventOutline = _eventOutline;


#define heightEventOutlineCell 52.0f

static UIFont *_titleFont = nil;
static UIFont *_detailFont = nil;
static UIColor *_titleColor = nil;
static UIColor *_detailColor = nil;
static UIColor *_disableColor = nil;

static NSString * const fbmarkPath = @"atndcal.bundle/images/mark/fbmark0808.png";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initATEventOutlineCell];
    }
    return self;
}

- (void)initATEventOutlineCell {
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [_eventOutline release];
    [super dealloc];
}

#pragma mark - setter

- (void)setEventOutline:(ATEventOutline *)eventOutline {
    if (_eventOutline != eventOutline) {
        [_eventOutline release];
        _eventOutline = [eventOutline retain];
        [self setNeedsDisplay];
    }
}

#pragma mark - Draw

- (void)drawContentView:(CGRect)r {
    [super drawContentView:r];
    
    LOG_FRAME(r);
    
    
	CGRect rect = CGRectInset(r, 3.0f, 3.0f);
	rect.origin.x += 24.0f;
    rect.size.width -= 24.0f;
    
	UIColor *textColor;
    textColor = ([_eventOutline isOver]) ? _disableColor : _titleColor;
    textColor = (self.selected || self.highlighted) ? [UIColor whiteColor] : textColor;
	[textColor set];

    [_eventOutline.title drawAtPoint:rect.origin 
                            forWidth:rect.size.width 
                            withFont:_titleFont 
                       lineBreakMode:UILineBreakModeTailTruncation];

    textColor = ([_eventOutline isOver]) ? _disableColor : _detailColor;
    textColor = (self.selected || self.highlighted) ? [UIColor whiteColor] : textColor;
    [textColor set];
    rect.origin.y += 17;
    [_eventOutline.date drawAtPoint:rect.origin 
                           forWidth:rect.size.width 
                           withFont:_detailFont 
                      lineBreakMode:UILineBreakModeTailTruncation];
    
    rect.origin.y += 14;
    [_eventOutline.place drawAtPoint:rect.origin 
                            forWidth:rect.size.width 
                            withFont:_detailFont 
                       lineBreakMode:UILineBreakModeTailTruncation];
    
    if (_eventOutline.type == ATEventTypeFacebook) {
        UIImage *fbImage = [[ATResource sharedATResource] imageOfPath:fbmarkPath];
        if ([_eventOutline isOver]) {
            [fbImage drawInRect:CGRectMake(4.0f, 4.0f, 16.0f, 16.0f) blendMode:kCGBlendModeNormal alpha:0.5];
        } else {
            [fbImage drawInRect:CGRectMake(4.0f, 4.0f, 16.0f, 16.0f)];
        }
    }

}


#pragma mark - Public 

+ (CGFloat)heightCell {
    return heightEventOutlineCell;
}


@end
