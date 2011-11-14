#import <Foundation/Foundation.h>


@interface NSString (ATCategory)
- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

+ (NSString *)stringForURLParam:(NSDictionary *)param method:(NSString *)method;
+ (NSString *)stringMapsUrlWithKeyword:(NSString *)keyword;
+ (NSString *)stringSearchGoogleUrlWithKeyword:(NSString *)keyword;
- (NSString *)stringByStrippingHTML;
+ (NSArray *)arrayExtractUrlFromString:(NSString*)aString;

@end
