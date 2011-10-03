//
//  ATNoticeInfoConnecter.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATNoticeInfoConnecter.h"
#import "ATCommon.h"

@interface ATNoticeInfoConnecter ()
- (void)initATNoticeInfoConnecter;
@end

@implementation ATNoticeInfoConnecter

- (id)init {
    if ((self = [super init])) {
        [self initATNoticeInfoConnecter];
    }
    return self;
}

- (void)initATNoticeInfoConnecter {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationNoticeInfoRequest:) 
                                                 name:ATNotificationNameNoticeInfoRequest 
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

#pragma mark - Public


- (void)checkNoticeInfo:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    
    static NSString *atndcalNoticeInfoUrl = kAtndcalNoticeInfoUrl;
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:atndcalNoticeInfoUrl] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameNoticeInfoRequest
                                                                          request:request] 
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}

#pragma mark - NoticeInfo Callback

- (void)notificationNoticeInfoRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                      encoding:NSUTF8StringEncoding] autorelease];
        NSArray *strings = [jsonString componentsSeparatedByString:@","];
        if (strings.count == 4) {
            NSInteger infoVersion = [[strings objectAtIndex:0] intValue];
            NSString *message = [strings objectAtIndex:1];
            NSString *buttonName = [strings objectAtIndex:2];
            NSString *buttonUrl = [strings objectAtIndex:3];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger dInfoVersion = [defaults integerForKey:kDefaultsNoticeInfoVersion];
            if (infoVersion > dInfoVersion) {
                [defaults setInteger:infoVersion forKey:kDefaultsNoticeInfoVersion];
                [defaults synchronize];

                ATAlertView *alertView = [[[ATAlertView alloc] initWithTitle:@"お知らせ" 
                                                                     message:message 
                                                           cancelButtonTitle:@"閉じる"] autorelease];
                
                if (buttonName.length > 0 && buttonUrl.length > 0) {
                    [alertView addButtonWithTitle:buttonName callback:^(ATAlertView *alertView, NSInteger index) {
                        NSURL *url = [NSURL URLWithString:buttonUrl];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }];
                }
                [alertView show];
            }
        }
    }
    
    POOL_END;
}

@end
