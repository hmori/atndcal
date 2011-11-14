#import <UIKit/UIKit.h>

@interface ATLabelTextFieldCell : UITableViewCell <UITextFieldDelegate> {
    CGFloat _widthLabel;
    UITextField *_field;

}
@property CGFloat widthLabel;
@property (nonatomic, retain) UITextField *field;

@end
