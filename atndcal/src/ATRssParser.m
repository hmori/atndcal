#import "ATRssParser.h"

@interface ATRssParser ()
@property (nonatomic, retain) ATRssChannel *channel;
@property (nonatomic, retain) NSMutableString *buffer;
@property (nonatomic, assign) ATRssItem *currentItem;
@end


@implementation ATRssParser

@synthesize channel = _channel;
@synthesize buffer = _buffer;
@synthesize items = _items;
@synthesize currentItem = _currentItem;

static NSString * const kRss = @"rss";
static NSString * const kChannel = @"channel";
static NSString * const kItem = @"item";
static NSString * const kTitle = @"title";
static NSString * const kLink = @"link";
static NSString * const kDescription = @"description";
static NSString * const kLanguage = @"language";
static NSString * const kTtl = @"ttl";
static NSString * const kPubDate = @"pubDate";
static NSString * const kLastBuildDate = @"lastBuildDate";
static NSString * const kAuthor = @"author";
static NSString * const kGuid = @"guid";


- (id)init {
    if ((self = [super init])) {
        self.items = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [_channel release];
    [_buffer release];
    [_items release];
    _currentItem = nil;
    [super dealloc];
}

#pragma mark - Public

- (void)parse:(NSData *)data {
    LOG_CURRENT_METHOD;

    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    parser.delegate = self;
    [parser parse];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser*)parser 
didStartElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qualifiedName 
    attributes:(NSDictionary*)attributeDict {

    if ([elementName isEqualToString:kRss]) {
        _isRss = YES;
    } else if ([elementName isEqualToString:kChannel]) {
        _isChannel = YES;
        self.channel = [[[ATRssChannel alloc] init] autorelease];
    } else if ([elementName isEqualToString:kItem]) {
        _isItem = YES;
        
        ATRssItem *item = [[[ATRssItem alloc] init] autorelease];
        [_items addObject:item];
        
        _currentItem = item;
    } else if ([elementName isEqualToString:kTitle] ||
               [elementName isEqualToString:kLink] ||
               [elementName isEqualToString:kDescription] ||
               [elementName isEqualToString:kLanguage] ||
               [elementName isEqualToString:kTtl] ||
               [elementName isEqualToString:kPubDate] ||
               [elementName isEqualToString:kLastBuildDate] ||
               [elementName isEqualToString:kAuthor] ||
               [elementName isEqualToString:kGuid]) {
        self.buffer = [NSMutableString stringWithCapacity:0];
    }
}

- (void)parser:(NSXMLParser*)parser 
 didEndElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qualifiedName {

    if ([elementName isEqualToString:kRss]) {
        _isRss = NO;
    } else if ([elementName isEqualToString:kChannel]) {
        _isChannel = NO;
    } else if ([elementName isEqualToString:kItem]) {
        _isItem = NO;
    } else if ([elementName isEqualToString:kTitle]) {
        if (_isItem) {
            _currentItem.title = _buffer;
        } else if (_isChannel) {
            _channel.title = _buffer;
        }
    } else if ([elementName isEqualToString:kLink]) {
        if (_isItem) {
            _currentItem.link = _buffer;
        } else if (_isChannel) {
            _channel.link = _buffer;
        }
    } else if ([elementName isEqualToString:kDescription]) {
        if (_isItem) {
            _currentItem.description_ = _buffer;
        } else if (_isChannel) {
            _channel.description_ = _buffer;
        }
    } else if ([elementName isEqualToString:kPubDate]) {
        if (_isItem) {
            _currentItem.pubDate = _buffer;
        } else if (_isChannel) {
            _channel.pubDate = _buffer;
        }
    } else if ([elementName isEqualToString:kLanguage]) {
        _channel.language = _buffer;
    } else if ([elementName isEqualToString:kTtl]) {
        _channel.ttl = _buffer;
    } else if ([elementName isEqualToString:kLastBuildDate]) {
        _channel.lastBuildDate = _buffer;
    } else if ([elementName isEqualToString:kAuthor]) {
        _currentItem.author = _buffer;
    } else if ([elementName isEqualToString:kGuid]) {
        _currentItem.guid = _buffer;
    }
    self.buffer = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_buffer appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [_channel.items setArray:_items];
}


@end
