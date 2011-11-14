#import <Foundation/Foundation.h>

extern NSString * const kDefaultsSettingAtndNickname;
extern NSString * const kDefaultsSettingAtndLoadDaysValue;
extern NSString * const kDefaultsSettingAutoLoadingValue;

@interface ATSetting : NSObject {
    NSDictionary *_rootPlist;
}
+ (ATSetting *)sharedATSetting;

- (void)registerDefaultsFromSettingsBundle;
- (NSArray *)preferenceSpecifiersOfRoot;
- (NSArray *)arrayForTitlesOfKey:(NSString *)key;
- (NSArray *)arrayForValuesOfKey:(NSString *)key;
- (NSUInteger)indexOfValue:(id)value key:(NSString *)key;
- (NSString *)stringTitleOfValue:(id)value key:(NSString *)key;
- (id)objectForItemKey:(NSString *)itemKey key:(NSString *)key;

@end
