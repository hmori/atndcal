//
//  ATSettingAutoLoadingViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATSettingAutoLoadingViewController.h"
#import "ATCommon.h"

@implementation ATSettingAutoLoadingViewController

#pragma mark - Overwride ATSettingSingleSelectViewController

- (NSString *)keyForValueOfUserDefaults {
    return kDefaultsSettingAutoLoadingValue;
}

- (NSString *)stringForFooter {
    return @"起動時に前回の検索条件で再更新を行います";
}

@end
