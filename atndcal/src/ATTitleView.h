#import <UIKit/UIKit.h>


@interface ATTitleView : UIView {
    UILabel *_titleLabel;
}
@property (nonatomic, retain) UILabel *titleLabel;

- (void)setTitle:(NSString *)text;

@end
