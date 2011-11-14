#import "ATLwwsXmlParser.h"

@interface ATLwwsXmlParser ()
@property (nonatomic, retain) NSMutableString *buffer;
@end


@implementation ATLwwsXmlParser
@synthesize lwws = _lwws;
@synthesize buffer = _buffer;

- (id)init {
    if ((self = [super init])) {
        self.lwws = [[[ATLwws alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    [_lwws release];
    [_buffer release];
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
    
    if ([elementName isEqualToString:@"pinpoint"]) {
        _isPinpoint = YES;
    } else if ([elementName isEqualToString:@"copyright"]) {
        _isCopyright = YES;
    } else if ([elementName isEqualToString:@"image"]) {
        _isImage = YES;
    } else if ([elementName isEqualToString:@"max"]) {
        _isMax = YES;
    } else if ([elementName isEqualToString:@"min"]) {
        _isMin = YES;
    } else if (
               ([elementName isEqualToString:@"title"] && !_isPinpoint && !_isCopyright && !_isImage) ||
               ([elementName isEqualToString:@"link"] && !_isPinpoint && !_isCopyright && !_isImage) || 
               [elementName isEqualToString:@"telop"] || 
               [elementName isEqualToString:@"description"] || 
               ([elementName isEqualToString:@"url"] && !_isPinpoint && !_isCopyright && _isImage) || 
               ([elementName isEqualToString:@"celsius"] && _isMax) || 
               ([elementName isEqualToString:@"celsius"] && _isMin)
               ) {
        self.buffer = [NSMutableString stringWithCapacity:0];
    }
}

- (void)parser:(NSXMLParser*)parser 
 didEndElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qualifiedName {

    if ([elementName isEqualToString:@"pinpoint"]) {
        _isPinpoint = NO;
    } else if ([elementName isEqualToString:@"copyright"]) {
        _isCopyright = NO;
    } else if ([elementName isEqualToString:@"image"]) {
        _isImage = NO;
    } else if ([elementName isEqualToString:@"max"]) {
        _isMax = NO;
    } else if ([elementName isEqualToString:@"min"]) {
        _isMin = NO;
    } else if ([elementName isEqualToString:@"title"] && !_isPinpoint && !_isCopyright && !_isImage) {
        _lwws.title = _buffer;
    } else if ([elementName isEqualToString:@"link"] && !_isPinpoint && !_isCopyright && !_isImage) {
        _lwws.link = _buffer;
    } else if ([elementName isEqualToString:@"telop"]) {
        _lwws.telop = _buffer;
    } else if ([elementName isEqualToString:@"description"]) {
        _lwws.description_ = _buffer;
    } else if ([elementName isEqualToString:@"url"] && !_isPinpoint && !_isCopyright && _isImage) {
        _lwws.imageUrl = _buffer;
    } else if (([elementName isEqualToString:@"celsius"] && _isMax)) {
        _lwws.maxCelsius = _buffer;
    } else if (([elementName isEqualToString:@"celsius"] && _isMin)) {
        _lwws.minCelsius = _buffer;
    }
    self.buffer = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_buffer appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

@end
