#import <UIKit/UIKit.h>


@interface ATProfileLabelView : UIView {
    UIImageView *_imageView;
    UIActivityIndicatorView *_indicatorView;

    UILabel *_label;
    NSString *_imageUrl;
}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, copy) NSString *imageUrl;

- (void)stopIndicator;

@end
