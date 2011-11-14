#import "ATLocalWebViewController.h"

@interface ATLocalWebViewController ()
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *titleString;
- (void)setupView;
@end

@implementation ATLocalWebViewController
@synthesize webView = _webView;
@synthesize filename = _filename;
@synthesize titleString = _titleString;

- (id)initWithFilename:(NSString *)filename title:(NSString *)title {
    if ((self = [super init])) {
        self.filename = filename;
        self.titleString = title;
    }
    return self;
}

- (void)dealloc {
    [_webView release];
    [_filename release];
    [_titleString release];
    [super dealloc];
}

- (void)loadView {
	LOG_CURRENT_METHOD;
	[super loadView];
    [self setupView];
}

- (void)viewDidLoad {
	LOG_CURRENT_METHOD;
    POOL_START;
    NSString *path = [[NSBundle mainBundle] resourcePath];
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURLRequest* request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//%@",path,_filename]]];
    [_webView loadRequest:request];
    POOL_END;
}

- (void)setupView {
    LOG_CURRENT_METHOD;
    POOL_START;
    CGFloat heightNavigationBar = self.navigationController.navigationBar.frame.size.height;
    CGRect rectView = self.view.bounds;
    CGRect rectWebView = CGRectMake(rectView.origin.x, 
                                    rectView.origin.y, 
                                    rectView.size.width, 
                                    rectView.size.height - heightNavigationBar);
	self.webView = [[[UIWebView alloc] initWithFrame:rectWebView] autorelease];
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];

	self.title = [self titleString];
    POOL_END;
}

@end