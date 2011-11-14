#import "ATLwws.h"
#import "ObjectSingleton.h"
#import "NSString+ATCategory.h"

@implementation ATLwwsManager

OBJECT_SINGLETON_TEMPLATE(ATLwwsManager, sharedATLwwsManager)

+ (NSString *)stringForDispDescription:(ATLwws *)lwws {
    LOG_CURRENT_METHOD;
    NSString *string = nil;
    string = [lwws.description_ stringByStrippingHTML];
    return string;
}

@end


@implementation ATLwws
@synthesize title = _title;
@synthesize link = _link;
@synthesize telop = _telop;
@synthesize description_ = _description_;
@synthesize imageUrl = _imageUrl;
@synthesize maxCelsius = _maxCelsius;
@synthesize minCelsius = _minCelsius;

- (void)dealloc {
    [_title release];
    [_link release];
    [_telop release];
    [_description_ release];
    [_imageUrl release];
    [_maxCelsius release];
    [_minCelsius release];

    [super dealloc];
}

@end
