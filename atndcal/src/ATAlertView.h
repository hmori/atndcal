#import <UIKit/UIKit.h>

@class ATAlertView;
typedef void (^ATAlertViewIndexBlock)(ATAlertView *alertView, NSInteger index);

@interface ATAlertView : UIAlertView <UIAlertViewDelegate> {
  @private
    void (^_willPresentCallbackBlock)(ATAlertView *);
    void (^_didPresentCallbackBlock)(ATAlertView *);
    void (^_willDismissCallbackBlock)(ATAlertView *, NSInteger);
    void (^_didDismissCallbackBlock)(ATAlertView *, NSInteger);
    
    NSMutableArray *_buttonCallbacks;
}
@property (nonatomic, retain) void (^willPresentCallbackBlock)(ATAlertView *);
@property (nonatomic, retain) void (^didPresentCallbackBlock)(ATAlertView *);
@property (nonatomic, retain) void (^willDismissCallbackBlock)(ATAlertView *, NSInteger);
@property (nonatomic, retain) void (^didDismissCallbackBlock)(ATAlertView *, NSInteger);

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)addButtonWithTitle:(NSString*)title callback:(ATAlertViewIndexBlock)callback;
- (void)setCancelButtonCallback:(ATAlertViewIndexBlock)callback;

@end