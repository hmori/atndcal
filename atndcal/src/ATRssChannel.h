//
//  ATRssChannel.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATRssChannel : NSObject {
    NSString *_title;
    NSString *_link;
    NSString *_description_;
    NSString *_language;
    NSString *_ttl;
    NSString *_pubDate;
    NSString *_lastBuildDate;
    NSMutableArray *_items;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *ttl;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *lastBuildDate;
@property (nonatomic, retain) NSMutableArray *items;


@end
