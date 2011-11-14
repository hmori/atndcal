#import "ATEkEventCell.h"

#import "NSDate+ATCategory.h"

@interface ATEkEventCell ()
- (void)initATEkEventCell;
@end


@implementation ATEkEventCell

@synthesize ekEvent = _ekEvent;

static UIFont *_titleFont = nil;
static UIFont *_detailFont = nil;
static UIColor *_detailColor = nil;

static NSString * const dateFormat = @"%@-%@";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initATEkEventCell];
    }
    return self;
}

- (void)initATEkEventCell {
    if (!_titleFont) {
        _titleFont = [[UIFont boldSystemFontOfSize:14] retain];
    }
    if (!_detailFont) {
        _detailFont = [[UIFont systemFontOfSize:12] retain];
    }
    if (!_detailColor) {
        _detailColor = [HEXCOLOR(0x2470D8FF) retain];
    }
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
    
	CGRect rect = CGRectInset(r, 22.0f, 3.0f);
	
	if(self.editing){
		rect.origin.x += 30.0f;
	}
	
    UIColor *detailTextColor = self.selected || self.highlighted ? [UIColor whiteColor] : _detailColor;
	UIColor *textColor = self.selected || self.highlighted ? [UIColor whiteColor] : [UIColor blackColor];

	[detailTextColor set];
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

    CGRect startDateRect = CGRectMake(rect.origin.x, rect.origin.y+3.0f, widthDate, 19.0f);
    [[startDate stringForDispDateYmw] drawAtPoint:startDateRect.origin 
                                                  forWidth:widthDate
                                                  withFont:_detailFont 
                                             lineBreakMode:UILineBreakModeTailTruncation];
    
    CGRect endDateRect = CGRectMake(rect.origin.x, rect.origin.y+19.0f, widthDate, 19.0f);
    [dateHm drawAtPoint:endDateRect.origin 
               forWidth:widthDate
               withFont:_detailFont 
          lineBreakMode:UILineBreakModeTailTruncation];

	[textColor set];
    
    CGRect titleRect = CGRectMake(rect.origin.x+widthDate, rect.origin.y+3.0f, rect.size.width-widthDate, 19.0f);
    [_ekEvent.title drawAtPoint:titleRect.origin 
                       forWidth:titleRect.size.width 
                       withFont:_titleFont 
                  lineBreakMode:UILineBreakModeTailTruncation];
    

    CGRect locationRect = CGRectMake(rect.origin.x+widthDate, rect.origin.y+21.0f, rect.size.width-widthDate, 19.0f);
    [_ekEvent.location drawAtPoint:locationRect.origin 
                          forWidth:locationRect.size.width 
                          withFont:_detailFont 
                     lineBreakMode:UILineBreakModeTailTruncation];
}


@end
