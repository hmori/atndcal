#import "ATSettingLoadDaysViewController.h"
#import "ATCommon.h"

@implementation ATSettingLoadDaysViewController

#pragma mark - Overwride ATSettingSingleSelectViewController

- (NSString *)keyForValueOfUserDefaults {
    return kDefaultsSettingAtndLoadDaysValue;
}

- (NSString *)stringForFooter {
    return @"更新時に取得開始した日付から設定した日数分のイベントを取得します";
}

@end
