#import "ATRssLdWeather.h"

@implementation ATRssLdWeather
@synthesize title = _title;
@synthesize id_ = _id_;
@synthesize source = _source;

- (void)dealloc {
    [_title release];
    [_id_ release];
    [_source release];
    [super dealloc];
}

@end
