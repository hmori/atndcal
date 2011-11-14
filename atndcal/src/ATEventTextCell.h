#import <UIKit/UIKit.h>

@interface ATEventTextCell : TKLabelFieldCell {
    BOOL _truncate;
}
@property (nonatomic, getter = isTruncate) BOOL truncate;
+ (CGFloat)heightCellOfLabelText:(NSString *)text truncate:(BOOL)truncate;

@end
