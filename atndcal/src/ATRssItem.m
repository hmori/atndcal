//
//  ATRssItem.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATRssItem.h"
#import "NSDate+ATCategory.h"

@implementation ATRssItemManager

+ (NSString *)stringForDispPubDate:(NSString *)dateString {
    
    static NSString *dateYmwhmFormat = @"%@ %@";
    
    NSDate *date = [NSDate dateForRssItemPubDateString:dateString];
    NSString *string = [NSString stringWithFormat:dateYmwhmFormat, [date stringForDispDateYmw], [date stringForDispDateHm]];
    return string;
}

+ (NSString *)stringForDispDescription:(NSString *)description {
    return [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end


@implementation ATRssItem
@synthesize title = _title;
@synthesize author = _author;
@synthesize link = _link;
@synthesize description_ = _description_;
@synthesize pubDate = _pubDate;
@synthesize guid = _guid;

- (void)dealloc {
    [_title release];
    [_author release];
    [_link release];
    [_description_ release];
    [_pubDate release];
    [_guid release];
    [super dealloc];
}

@end
