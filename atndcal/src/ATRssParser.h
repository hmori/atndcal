//
//  ATRssParser.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATRssChannel.h"
#import "ATRssItem.h"

@interface ATRssParser : NSObject <NSXMLParserDelegate> {
  @private
    ATRssChannel *_channel;
    NSMutableString *_buffer;
    NSMutableArray *_items;

    ATRssItem *_currentItem; // Assign
    BOOL _isRss;
    BOOL _isChannel;
    BOOL _isItem;
}
@property (nonatomic, retain) NSMutableArray *items;

- (void)parse:(NSData *)data;
@end
