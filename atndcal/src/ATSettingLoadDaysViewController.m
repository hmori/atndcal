//
//  ATSettingLoadDaysViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
