#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@class ATTitleView;


@interface ATWebViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *_webView;
    NSString *_initUrlString;
    NSString *_currentUrlString;
    ATTitleView *_titleView;
    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
}
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, copy) NSString *initUrlString;
@property (nonatomic, copy) NSString *currentUrlString;
@property (nonatomic, retain) ATTitleView *titleView;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *forwardButton;


- (id)initWithUrlString:(NSString *)urlString;
- (void)closeAction:(id)sender;
- (void)otherAction:(id)sender;
- (void)firstLoadAction:(id)sender;
- (void)reloadAction:(id)sender;
- (void)backAction:(id)sender;
- (void)forwardAction:(id)sender;

@end
