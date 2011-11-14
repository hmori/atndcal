#import <Foundation/Foundation.h>


@interface ATRssChannel : NSObject {
  @private
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
