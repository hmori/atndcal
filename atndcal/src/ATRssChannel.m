//
//  ATRssChannel.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATRssChannel.h"


@implementation ATRssChannel

@synthesize title = _title;
@synthesize link = _link;
@synthesize description_ = _description_;
@synthesize language = _language;
@synthesize ttl = _ttl;
@synthesize pubDate = _pubDate;
@synthesize lastBuildDate = _lastBuildDate;
@synthesize items = _items;

- (void)dealloc {
    [_title release];
    [_link release];
    [_description_ release];
    [_language release];
    [_ttl release];
    [_pubDate release];
    [_lastBuildDate release];
    [_items release];
    [super dealloc];
}

@end
