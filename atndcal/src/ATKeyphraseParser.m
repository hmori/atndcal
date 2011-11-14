#import "ATKeyphraseParser.h"

@interface ATKeyphraseParser ()
@property (nonatomic, assign) ATKeyphraseResult *currentResult;
@property (nonatomic, retain) NSMutableString *buffer;
@end


@implementation ATKeyphraseParser
@synthesize results = _results;
@synthesize currentResult = _currentResult;
@synthesize buffer = _buffer;

static NSString * const ResultSet = @"ResultSet";
static NSString * const Result = @"Result";
static NSString * const Keyphrase = @"Keyphrase";
static NSString * const Score = @"Score";


- (id)init {
    if ((self = [super init])) {
        POOL_START;
        self.results = [NSMutableArray arrayWithCapacity:0];
        POOL_END;
    }
    return self;
}


- (void)dealloc {
    [_results release];
    [_buffer release];
    _currentResult = nil;
    [super dealloc];
}

#pragma mark - Public


- (void)parse:(NSData *)data {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    parser.delegate = self;
    [parser parse];
    
    POOL_END;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser*)parser 
didStartElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qualifiedName 
    attributes:(NSDictionary*)attributeDict {
    
    if ([elementName isEqualToString:ResultSet]) {
        _isResultSet = YES;
    } else if ([elementName isEqualToString:Result]) {
        _isResult = YES;
        
        ATKeyphraseResult *result = [[[ATKeyphraseResult alloc] init] autorelease];
        [_results addObject:result];
        
        _currentResult = result;
    } else if ([elementName isEqualToString:Keyphrase] ||
               [elementName isEqualToString:Score]) {
        self.buffer = [NSMutableString stringWithCapacity:0];
    }
}

- (void)parser:(NSXMLParser*)parser 
 didEndElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qualifiedName {
    
    if ([elementName isEqualToString:ResultSet]) {
        _isResultSet = NO;
    } else if ([elementName isEqualToString:Result]) {
        _isResult = NO;
    } else if ([elementName isEqualToString:Keyphrase]) {
        if (_isResultSet && _isResult) {
            _currentResult.keyphrase = _buffer;
        }
    } else if ([elementName isEqualToString:Score]) {
        if (_isResultSet && _isResult) {
            _currentResult.score = _buffer;
        }
    }
    self.buffer = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_buffer appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}


@end
