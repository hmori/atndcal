//
//  AppDelegate.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/07/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ATCommon.h"

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
    
    [[ATSetting sharedATSetting] registerDefaultsFromSettingsBundle];
    _facebookConnecter = [[ATFacebookConnecter alloc] init];
    _noticeInfoConnecter = [[ATNoticeInfoConnecter alloc] init];
    [_noticeInfoConnecter checkNoticeInfo:nil];

    
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
    LOG(@"%@ [%@|%@|%@|%@]", url, url.scheme, url.host, url.path, url.query);
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