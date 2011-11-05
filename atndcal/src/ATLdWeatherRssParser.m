//
//  ATLdWeatherRssParser.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATLdWeatherRssParser.h"
#import "ATRssLdWeather.h"


@interface ATLdWeatherRssParser ()
@end


@implementation ATLdWeatherRssParser
@synthesize ldWeathers = _ldWeathers;

static NSString * const kCity = @"city";
static NSString * const kTitle = @"title";
static NSString * const kId = @"id";
static NSString * const kSource = @"source";


- (id)init {
    if ((self = [super init])) {
        self.ldWeathers = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [_ldWeathers release];
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
    
    if ([elementName isEqualToString:kCity]) {
        
        ATRssLdWeather *rssLdWeather = [[[ATRssLdWeather alloc] init] autorelease];
        rssLdWeather.title = [attributeDict objectForKey:kTitle];
        rssLdWeather.id_ = [attributeDict objectForKey:kId];
        rssLdWeather.source = [attributeDict objectForKey:kSource];
        [_ldWeathers addObject:rssLdWeather];
    }
}

- (void)parser:(NSXMLParser*)parser 
 didEndElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qualifiedName {
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

@end
