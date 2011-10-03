//
//  ATRssItem.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATRssItemManager : NSObject {
    
}
+ (NSString *)stringForDispPubDate:(NSString *)dateString;
+ (NSString *)stringForDispDescription:(NSString *)description;
@end

@interface ATRssItem : NSObject {
    NSString *_title;
    NSString *_author;
    NSString *_link;
    NSString *_description_;
    NSString *_pubDate;
    NSString *_guid;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *guid;

@end
