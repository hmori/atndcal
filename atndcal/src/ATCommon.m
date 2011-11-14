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
