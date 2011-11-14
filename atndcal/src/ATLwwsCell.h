#import <UIKit/UIKit.h>
#import "ATEventTextCell.h"

@interface ATLwwsCell : ATEventTextCell {
  @private
    UIImageView *_iconImageView;
    UILabel *_pubDateLabel;
}
@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *pubDateLabel;

+ (CGFloat)heightCellOfLabelText:(NSString *)text truncate:(BOOL)truncate;

@end
