//
//  ATRssLdWeather.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
