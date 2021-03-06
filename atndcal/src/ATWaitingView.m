#import "ATWaitingView.h"

@implementation ATWaitingView
@synthesize title;
@synthesize message;

- (id)init {
    if ((self = [super init])) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [self initWithFrame:window.frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _loadingView = [[TKLoadingView alloc] initWithTitle:nil];
        [_loadingView startAnimating];
        _loadingView.center = self.center;
        [self addSubview:_loadingView];
    }
    return self;
}

- (void)dealloc {
    [_loadingView release];
    [super dealloc];
}

#pragma mark - Public

- (void)setTitle:(NSString *)str {
    [_loadingView setTitle:str];
}

- (void)setMessage:(NSString*)str {
    [_loadingView setMessage:str];
}


@end
