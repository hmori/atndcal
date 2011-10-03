//
//  NSString+ATCategory.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+ATCategory.h"
#import "RegexKitLite.h"

@implementation NSString (ATCategory)

static NSString *mapsUrlFormat = @"http://maps.google.com/maps?q=%@";
static NSString *searchGoogleUrlFormat = @"http://www.google.co.jp/search?q=%@&hl=ja&ie=UTF-8&oe=UTF-8";


- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGFloat fontSize = [font pointSize];
    CGFloat height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    UIFont *newFont = font;
    
    while (height > size.height && height != 0) {   
        fontSize--;  
        newFont = [UIFont fontWithName:font.fontName size:fontSize];   
        height = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    };
    
    for (NSString *word in [self componentsSeparatedByString:@" "]) {
        CGFloat width = [word sizeWithFont:newFont].width;
        while (width > size.width && width != 0) {
            fontSize--;
            newFont = [UIFont fontWithName:font.fontName size:fontSize];   
            width = [word sizeWithFont:newFont].width;
        }
    }
    return fontSize;
}

+ (NSString *)stringForURLParam:(NSDictionary *)param method:(NSString *)method {
	NSMutableString *str = [NSMutableString stringWithCapacity:0];
	NSArray *keys = [param allKeys];
    BOOL isGet = ([method isEqualToString:@"GET"]?YES:NO);
	BOOL first = YES;
	for (id key in keys) {
		if (first) {
			first = NO;
            if (isGet) {
                [str appendString:@"?"];
            }
		} else {
			[str appendString:@"&"];
		}
		[str appendFormat:@"%@=%@", key, [param objectForKey:key]];
	}
	return str;
}


+ (NSString *)stringMapsUrlWithKeyword:(NSString *)keyword {
    return [NSString stringWithFormat:mapsUrlFormat, [keyword URLEncode]];
}

+ (NSString *)stringSearchGoogleUrlWithKeyword:(NSString *)keyword {
    return [NSString stringWithFormat:searchGoogleUrlFormat, [keyword URLEncode]];
}

- (NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *string = [[self copy] autorelease];
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    }
    return string;
}

+ (NSArray *)arrayExtractUrlFromString:(NSString*)aString {
    static NSString *matcherRegexUrlString = @"(https?://[^ \u201c\u201d　|()\r\n]+)";
    
    NSMutableArray *urlArray = [NSMutableArray arrayWithCapacity:0];
	NSArray *tokenArray = [aString componentsMatchedByRegex:matcherRegexUrlString];
	for (NSString *token in tokenArray) {
		if (![urlArray containsObject:token]) {
			[urlArray addObject:token];
		}
	}
    return urlArray;
}


/*
static void charactersParsed(void* context, const xmlChar* ch, int len) {
    NSMutableString* result = context;
    NSString* parsedString;
    parsedString = [[NSString alloc] initWithBytesNoCopy:
                    (xmlChar*) ch length: len encoding:
                    NSUTF8StringEncoding freeWhenDone: NO];
    [result appendString: parsedString];
    [parsedString release];
}

static void structuredError(void * userData, xmlErrorPtr error) {
    (void)userData;
    (void)error;
}

- (NSString*) flattenHTML {
    int mem_base = xmlMemBlocks();
    NSMutableString* result = [NSMutableString string];
    xmlSAXHandler handler; bzero(&handler,
                                 sizeof(xmlSAXHandler));
    handler.characters = &charactersParsed;
    
    xmlSetStructuredErrorFunc(xmlGenericErrorContext,
                              &structuredError);
    
    htmlSAXParseDoc((xmlChar*)[self UTF8String], "utf-8",
                    &handler, result);
    
    if (mem_base != xmlMemBlocks()) {
        NSLog( @"Leak of %d blocks found in htmlSAXParseDoc",
              xmlMemBlocks() - mem_base);
    }
    return result;
}
*/

@end
