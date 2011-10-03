//
//  AppDelegate.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/07/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATCalendarTableViewController.h"
#import "ATFacebookConnecter.h"
#import "ATNoticeInfoConnecter.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
  @private
    ATCalendarTableViewController *_calenderCtl;
    UINavigationController *_nav;
    ATFacebookConnecter *_facebookConnecter;
    ATNoticeInfoConnecter *_noticeInfoConnecter;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) ATCalendarTableViewController *calenderCtl;
@property (nonatomic, readonly) ATFacebookConnecter *facebookConnecter;

@end
