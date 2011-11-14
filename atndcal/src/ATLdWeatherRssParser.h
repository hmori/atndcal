#import <Foundation/Foundation.h>

@interface ATLdWeatherRssParser : NSObject <NSXMLParserDelegate> {
  @private
    NSMutableArray *_ldWeathers;
}
@property (nonatomic, retain) NSMutableArray *ldWeathers;

- (void)parse:(NSData *)data;

@end
