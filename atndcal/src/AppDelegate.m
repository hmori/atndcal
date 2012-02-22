#import "AppDelegate.h"
#import "ATCommon.h"

#import "ATLdWeatherConnecter.h"

@interface AppDelegate ()
@end


@implementation AppDelegate

@synthesize window=_window;
@synthesize calenderCtl = _calenderCtl;
@synthesize facebookConnecter = _facebookConnecter;

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_calenderCtl release];
    [_nav release];
    [_window release];
    [_facebookConnecter release];
    [_noticeInfoConnecter release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [dictionnary release];

    
    [[ATSetting sharedATSetting] registerDefaultsFromSettingsBundle];
    _facebookConnecter = [[ATFacebookConnecter alloc] init];
    _noticeInfoConnecter = [[ATNoticeInfoConnecter alloc] init];
    [_noticeInfoConnecter checkNoticeInfo:nil];

    [[ATLdWeatherConnecter sharedATLdWeatherConnecter] forecastConnect];
    
    _calenderCtl = [[ATCalendarTableViewController alloc] init];
    _nav = [[UINavigationController alloc] initWithRootViewController:_calenderCtl];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window addSubview:_nav.view];
    [self.window makeKeyAndVisible];
    
    POOL_END;
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL*)url {
    LOG_CURRENT_METHOD;
    [_facebookConnecter.facebook handleOpenURL:url];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    LOG_CURRENT_METHOD;
#if DEBUG
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        LOG(@"cookie=%@", cookie);
    }
#endif
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}


@end
