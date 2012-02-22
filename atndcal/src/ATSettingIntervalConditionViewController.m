#import "ATSettingIntervalConditionViewController.h"
#import "ATCommon.h"

@implementation ATSettingIntervalConditionViewController

#pragma mark - Overwride ATSettingSingleSelectViewController

- (NSString *)keyForValueOfUserDefaults {
    return kDefaultsSettingAtndIntervalConditionValue;
}

- (NSString *)stringForFooter {
    return @"更新時に指定日数以上のイベントを無視します";
}

@end
