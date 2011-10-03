//
//  ATCommon.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATCommon.h"

NSString * const kDefaultsNoticeInfoVersion = @"kDefaultsNoticeInfoVersion";
NSString * const kDefaultsFinalCalendarSearchText = @"kDefaultsFinalCalendarSearchText";
NSString * const kDefaultsFacebookMeData = @"kDefaultsFacebookMeData";

@implementation ATCommon

+ (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

+ (ATFacebookConnecter *)facebookConnecter {
    return [[self.class appDelegate] facebookConnecter];
}

@end
