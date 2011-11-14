#import <UIKit/UIKit.h>

@interface ATWaitingView : UIView {
  @private
    TKLoadingView *_loadingView;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;


@end
