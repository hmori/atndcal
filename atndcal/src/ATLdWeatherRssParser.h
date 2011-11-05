//
//  ATLdWeatherRssParser.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATLdWeatherRssParser : NSObject <NSXMLParserDelegate> {
  @private
    NSMutableArray *_ldWeathers;
}
@property (nonatomic, retain) NSMutableArray *ldWeathers;

- (void)parse:(NSData *)data;

@end
