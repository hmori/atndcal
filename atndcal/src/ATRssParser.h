#import <Foundation/Foundation.h>

#import "ATRssChannel.h"
#import "ATRssItem.h"

@interface ATRssParser : NSObject <NSXMLParserDelegate> {
  @private
    ATRssChannel *_channel;
    NSMutableString *_buffer;
    NSMutableArray *_items;

    ATRssItem *_currentItem; //week reference
    BOOL _isRss;
    BOOL _isChannel;
    BOOL _isItem;
}
@property (nonatomic, retain) NSMutableArray *items;

- (void)parse:(NSData *)data;
@end
