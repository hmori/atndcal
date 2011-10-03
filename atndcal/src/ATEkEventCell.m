//
//  ATEkEventCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEkEventCell.h"

#import "NSDate+ATCategory.h"

@implementation ATEkEventCell

@synthesize ekEvent = _ekEvent;

static UIFont *_titleFont = nil;
static UIFont *_detailFont = nil;

static NSString * const dateFormat = @"%@-%@";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_titleFont = [[UIFont boldSystemFontOfSize:14] retain];
		_detailFont = [[UIFont systemFontOfSize:12] retain];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [_ekEvent release];
    [super dealloc];
}

#pragma mark - Public

- (void)setEKEvent:(EKEvent *)ekEvent {
    if (_ekEvent != ekEvent) {
        [_ekEvent release];
        _ekEvent = [ekEvent retain];
        [self setNeedsDisplay];
    }
}

#pragma mark - Private


#pragma mark - Draw

- (void)drawContentView:(CGRect)r {
    [super drawContentView:r];
    
    CGFloat widthDate = 80.0f;
    
	CGRect rect = CGRectInset(r, 22, 3);
	
	if(self.editing){
		rect.origin.x += 30;
	}
	
	UIColor *textColor = self.selected || self.highlighted ? [UIColor whiteColor] : [UIColor blackColor];
	[textColor set];
    
    NSDate *startDate = _ekEvent.startDate;
    NSDate *endDate = _ekEvent.endDate;
    
    NSString *dateHm = nil;
    if ([startDate isSameDay:endDate]) {
        dateHm = [NSString stringWithFormat:dateFormat, 
                  [startDate stringForDispDateHm], 
                  [endDate stringForDispDateHm]];
    } else {
        dateHm = [startDate stringForDispDateHm];
    }

    CGRect startDateRect = CGRectMake(rect.origin.x, rect.origin.y+3, widthDate, 19);
    [[startDate stringForDispDateYmw] drawAtPoint:startDateRect.origin 
                                                  forWidth:widthDate
                                                  withFont:_detailFont 
                                             lineBreakMode:UILineBreakModeTailTruncation];
    
    CGRect endDateRect = CGRectMake(rect.origin.x, rect.origin.y+19, widthDate, 19);
    [dateHm drawAtPoint:endDateRect.origin 
               forWidth:widthDate
               withFont:_detailFont 
          lineBreakMode:UILineBreakModeTailTruncation];

    CGRect titleRect = CGRectMake(rect.origin.x+widthDate, rect.origin.y, rect.size.width-widthDate, 19);
    [_ekEvent.title drawAtPoint:titleRect.origin 
                       forWidth:titleRect.size.width 
                       withFont:_titleFont 
                  lineBreakMode:UILineBreakModeTailTruncation];
    

    CGRect locationRect = CGRectMake(rect.origin.x+widthDate, rect.origin.y+19, rect.size.width-widthDate, 19);
    [_ekEvent.location drawAtPoint:locationRect.origin 
                          forWidth:locationRect.size.width 
                          withFont:_detailFont 
                     lineBreakMode:UILineBreakModeTailTruncation];
}


@end
