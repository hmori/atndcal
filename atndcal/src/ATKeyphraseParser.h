//
//  ATKeyphraseParser.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/09/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATKeyphraseResult.h"

@interface ATKeyphraseParser : NSObject <NSXMLParserDelegate> {
    NSMutableArray *_results;
    NSMutableString *_buffer;
  
    ATKeyphraseResult *_currentResult; // Assign

    BOOL _isResultSet;
    BOOL _isResult;
}
@property (nonatomic, retain) NSMutableArray *results;

- (void)parse:(NSData *)data;

@end
