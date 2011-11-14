#import <Foundation/Foundation.h>


@interface ATResource : NSObject {
  @private
    NSMutableDictionary *_resouceDictionary;
}
+ (ATResource *)sharedATResource;

- (UIImage *)imageOfPath:(NSString *)path;

@end
