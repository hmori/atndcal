#import <UIKit/UIKit.h>


@interface ATLocalWebViewController : UIViewController {
  @private
    UIWebView *_webView;
    NSString *_filename;
    NSString *_titleString;
}

- (id)initWithFilename:(NSString *)filename title:(NSString *)title;

@end
