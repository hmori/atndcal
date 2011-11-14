#import <UIKit/UIKit.h>
#import "ATEventOutline.h"

@interface ATEventOutlineCell : TKIndicatorCell {
    ATEventOutline *_eventOutline;
}
@property (nonatomic, retain) ATEventOutline *eventOutline;


+ (CGFloat)heightCell;

@end
