//
//  ATLwwsXmlParser.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLwws.h"

@interface ATLwwsXmlParser : NSObject <NSXMLParserDelegate> {
  @private
    ATLwws *_lwws;
    NSMutableString *_buffer;
    
    BOOL _isPinpoint;
    BOOL _isCopyright;
    BOOL _isImage;
    BOOL _isMax;
    BOOL _isMin;
}
@property (nonatomic, retain) ATLwws *lwws;

- (void)parse:(NSData *)data;

@end
