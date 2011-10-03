//
//  ATCommon.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ATSetting.h"
#import "ATOperationManager.h"
#import "ATResource.h"
#import "ATActionSheet.h"
#import "ATAlertView.h"
#import "NSMutableURLRequest+ATCategory.h"

extern NSString * const kDefaultsNoticeInfoVersion;
extern NSString * const kDefaultsFinalCalendarSearchText;
extern NSString * const kDefaultsFacebookMeData;

@interface ATCommon : NSObject {
    
}
+ (AppDelegate *)appDelegate;
+ (ATFacebookConnecter *)facebookConnecter;

@end