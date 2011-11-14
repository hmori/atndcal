#import <UIKit/UIKit.h>
#import "ATEventTextCell.h"


@interface ATEventCommentCell : ATEventTextCell {
    UILabel *_pubDateLabel;
}
@property (nonatomic, retain) UILabel *pubDateLabel;

@end
