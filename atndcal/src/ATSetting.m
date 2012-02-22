#import "ATSetting.h"
#import "ObjectSingleton.h"

NSString * const kDefaultsSettingAtndNickname = @"kDefaultsSettingAtndNickname";
NSString * const kDefaultsSettingAtndLoadDaysValue = @"kDefaultsSettingAtndLoadDaysValue";
NSString * const kDefaultsSettingAtndIntervalConditionValue = @"kDefaultsSettingAtndIntervalConditionValue";
NSString * const kDefaultsSettingAutoLoadingValue = @"kDefaultsSettingAutoLoadingValue";

@implementation ATSetting

OBJECT_SINGLETON_TEMPLATE(ATSetting, sharedATSetting)

static NSString * const PreferenceSpecifiers = @"PreferenceSpecifiers";
static NSString * const Root = @"Root";
static NSString * const plist = @"plist";
static NSString * const Key = @"Key";
static NSString * const Titles = @"Titles";
static NSString * const Values = @"Values";
static NSString * const DefaultValue = @"DefaultValue";

static NSString * const SettingBundleName = @"Settings.bundle";

- (void)dealloc {
    [_rootPlist release];
    [super dealloc];
}

#pragma mark - Public

- (void)registerDefaultsFromSettingsBundle {
    LOG_CURRENT_METHOD;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *preferenceSpecifiers = [self preferenceSpecifiersOfRoot];
    for (NSDictionary *item in preferenceSpecifiers) {
        NSString *identifier = [item objectForKey:Key];
        if (identifier) {
            if (![defaults objectForKey:identifier]) {
                id defaultValue = [item objectForKey:DefaultValue];
                [defaults setObject:defaultValue forKey:identifier];
            }
        }
    }
    [defaults synchronize];
}


- (NSArray *)preferenceSpecifiersOfRoot {
    
    if (!_rootPlist) {
        NSString *settingBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:SettingBundleName];
        NSBundle *settingBundle = [NSBundle bundleWithPath:settingBundlePath];
        NSString *rootPlistPath = [settingBundle pathForResource:Root ofType:plist];
        _rootPlist = [[NSDictionary dictionaryWithContentsOfFile:rootPlistPath] retain];
    }
    return [_rootPlist objectForKey:PreferenceSpecifiers];
}

- (NSArray *)arrayForTitlesOfKey:(NSString *)key {
    NSArray *titles = nil;
    NSArray *preferenceSpecifiers = [self preferenceSpecifiersOfRoot];
    for (NSDictionary *item in preferenceSpecifiers) {
        NSString *identifier = [item objectForKey:Key];
        if (identifier && [identifier isEqualToString:key]) {
            titles = [item objectForKey:Titles];
            break;
        }
    }
    return titles;
}

- (NSArray *)arrayForValuesOfKey:(NSString *)key {
    NSArray *values = nil;
    NSArray *preferenceSpecifiers = [self preferenceSpecifiersOfRoot];
    for (NSDictionary *item in preferenceSpecifiers) {
        NSString *identifier = [item objectForKey:Key];
        if (identifier && [identifier isEqualToString:key]) {
            values = [item objectForKey:Values];
            break;
        }
    }
    return values;
}

- (NSUInteger)indexOfValue:(id)value key:(NSString *)key {
    NSArray *valueArray = [self arrayForValuesOfKey:key];
    return [valueArray indexOfObject:value];
}

- (NSString *)stringTitleOfValue:(id)value key:(NSString *)key {
    NSString *title = nil;
    NSUInteger index = [self indexOfValue:value key:key];
    if (index != NSNotFound) {
        NSArray *titleArray = [self arrayForTitlesOfKey:key];
        title = [titleArray objectAtIndex:index];
    }
    return title;
}

- (id)objectForItemKey:(NSString *)itemKey key:(NSString *)key {
    id object = nil;
    NSArray *preferenceSpecifiers = [self preferenceSpecifiersOfRoot];
    for (NSDictionary *item in preferenceSpecifiers) {
        NSString *identifier = [item objectForKey:Key];
        if (identifier && [identifier isEqualToString:key]) {
            object = [item objectForKey:itemKey];
            break;
        }
    }
    return object;
}


@end
