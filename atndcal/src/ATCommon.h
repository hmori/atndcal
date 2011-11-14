#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ATSetting.h"
#import "ATOperationManager.h"
#import "ATResource.h"
#import "ATActionSheet.h"
#import "ATAlertView.h"
#import "NSMutableURLRequest+ATCategory.h"
#import "ATEvernoteConnecter.h"
#import "ATTitleView.h"
#import "ATWaitingView.h"

extern NSString * const kDefaultsNoticeInfoVersion;
extern NSString * const kDefaultsFinalCalendarSearchText;
extern NSString * const kDefaultsFacebookMeData;

@interface ATCommon : NSObject {
    
}
+ (AppDelegate *)appDelegate;
+ (ATFacebookConnecter *)facebookConnecter;

@end
