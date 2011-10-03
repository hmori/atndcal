//
//  NSString+ATCategory.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (ATCategory)
- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

+ (NSString *)stringForURLParam:(NSDictionary *)param method:(NSString *)method;
+ (NSString *)stringMapsUrlWithKeyword:(NSString *)keyword;
+ (NSString *)stringSearchGoogleUrlWithKeyword:(NSString *)keyword;
- (NSString *)stringByStrippingHTML;
+ (NSArray *)arrayExtractUrlFromString:(NSString*)aString;

@end
