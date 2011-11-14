#import <UIKit/UIKit.h>
#import "ATEventOutline.h"

@interface ATEventOutlineGroupedCell : UITableViewCell {
    ATEventOutline *_eventOutline;
    
    UILabel *_titleLabel;
    UILabel *_dateLabel;
    UILabel *_placeLabel;
}
@property (nonatomic, retain) ATEventOutline *eventOutline;


+ (CGFloat)heightCell;

@end
