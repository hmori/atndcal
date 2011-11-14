#import "ATWebViewController.h"
#import "ATCommon.h"

#define heightToolbar 44.0f

@interface ATWebViewController ()
- (void)initATWebViewController;
- (void)setupView;
- (UIWebView *)webViewWithFrame:(CGRect)rect;
- (UIToolbar *)footerToolbarWithFrame:(CGRect)rect;
- (void)openSafari:(id)sender;
@end


@implementation ATWebViewController

@synthesize webView = _webView;
@synthesize initUrlString = _initUrlString;
@synthesize currentUrlString = _currentUrlString;
@synthesize titleView = _titleView;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;

- (id)initWithUrlString:(NSString *)urlString {
    if ((self = [super init])) {
        self.initUrlString = urlString;
        self.currentUrlString = urlString;
        [self initATWebViewController];
    }
    return self;
}

- (void)initATWebViewController {
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    _webView.delegate = nil;
    [_webView release];
    [_initUrlString release];
    [_currentUrlString release];
    [_titleView release];
    [_backButton release];
    [_forwardButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView {
    LOG_CURRENT_METHOD;
    [super loadView];
    [self setupView];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    [self firstLoadAction:nil];
}

- (void)viewDidUnload {
    LOG_CURRENT_METHOD;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
	LOG_CURRENT_METHOD;
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	LOG_CURRENT_METHOD;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	LOG_CURRENT_METHOD;
    POOL_START;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *documentTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [_titleView setTitle:documentTitle];
    self.currentUrlString = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    
    self.backButton.enabled = [webView canGoBack];
    self.forwardButton.enabled = [webView canGoForward];
    POOL_END;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	LOG_CURRENT_METHOD;
    POOL_START;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger err_code = [error code];
	LOG(@"error code=%d", err_code);
	if (err_code != NSURLErrorCancelled) { // 読み込みストップの場合は何もしない
        NSString *message = [NSString stringWithFormat:@"%@", [error localizedDescription]];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
	}
    
    self.backButton.enabled = [webView canGoBack];
    self.forwardButton.enabled = [webView canGoForward];
    POOL_END;
}

#pragma mark - Private

- (void)setupView {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    CGFloat heightNavigationBar = self.navigationController.navigationBar.frame.size.height;
    CGRect rectView = self.view.bounds;
    CGRect rectWebView = CGRectMake(rectView.origin.x, 
                                    rectView.origin.y, 
                                    rectView.size.width, 
                                    rectView.size.height - heightNavigationBar - heightToolbar);
    CGRect rectToolbar = CGRectMake(rectView.origin.x, 
                                    rectView.size.height - heightNavigationBar - heightToolbar, 
                                    rectView.size.width, 
                                    heightToolbar);
    
    self.webView = [self webViewWithFrame:rectWebView];
	[self.view addSubview:_webView];

    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"閉じる" 
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:self 
                                                                                 action:@selector(closeAction:)] autorelease];
    }

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                            target:self 
                                                                                            action:@selector(otherAction:)] autorelease];
    
    self.titleView = [[[ATTitleView alloc] init] autorelease];
    [_titleView setTitle:_initUrlString];
    self.navigationItem.titleView = _titleView;

    [self.view addSubview:[self footerToolbarWithFrame:rectToolbar]];
    
    POOL_END;
}

- (UIWebView *)webViewWithFrame:(CGRect)rect {
    LOG_CURRENT_METHOD;
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:rect] autorelease];
	webView.scalesPageToFit = YES;
	webView.delegate = self;
    return webView;
}

- (UIToolbar *)footerToolbarWithFrame:(CGRect)rect {
    LOG_CURRENT_METHOD;
    
    UIToolbar *footerToolbar = [[[UIToolbar alloc] initWithFrame:rect] autorelease];
    
	UIBarButtonItem *reloadButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                   target:self 
                                                                                   action:@selector(reloadAction:)] autorelease];
    
	UIBarButtonItem *firstLoadButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind 
                                                                                      target:self 
                                                                                      action:@selector(firstLoadAction:)] autorelease];
    
    
	self.backButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay 
                                                                     target:self 
                                                                     action:@selector(backAction:)] autorelease];
    _backButton.enabled = NO;
    UIToolbar *bar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.01f)] autorelease];
    bar.transform = CGAffineTransformMakeScale(-1.0f,1.0f);
    [bar setItems:[NSArray arrayWithObject:_backButton]];
    UIBarButtonItem *wrappedBackButton = [[[UIBarButtonItem alloc] initWithCustomView:bar] autorelease];
    
    
	self.forwardButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay 
                                                                        target:self 
                                                                        action:@selector(forwardAction:)] autorelease];
    _forwardButton.enabled = NO;
    
	UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil] autorelease];
    
    [footerToolbar setItems:[NSArray arrayWithObjects:flexSpace, 
                             reloadButton, flexSpace, 
                             firstLoadButton, flexSpace, 
                             wrappedBackButton, flexSpace, 
                             _forwardButton, flexSpace, nil]];
    
    return footerToolbar;
}

- (void)openSafari:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSURL *url = [NSURL URLWithString:_currentUrlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    POOL_END;
}

#pragma mark - Public

- (void)closeAction:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)otherAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:_titleView.titleLabel.text] autorelease];
    [actionSheet addButtonWithTitle:@"Safariで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openSafari:sender];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)firstLoadAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSString *url = _initUrlString;
    if ([_initUrlString hasSuffix:@".xml"]) {
        static NSString *macReaderUrlFormat = @"http://reader.mac.com/mobile/v1/%@";
        url = [NSString stringWithFormat:macReaderUrlFormat, [_initUrlString URLEncode]];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[_webView loadRequest:req];
    POOL_END;
}

- (void)reloadAction:(id)sender {
    LOG_CURRENT_METHOD;
	[_webView reload];
}

- (void)backAction:(id)sender {
    LOG_CURRENT_METHOD;
    [_webView goBack];
}

- (void)forwardAction:(id)sender {
    LOG_CURRENT_METHOD;
    [_webView goForward];
}

@end
