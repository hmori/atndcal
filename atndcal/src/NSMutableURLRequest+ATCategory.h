//
//  NSMutableURLRequest+ATCategory.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/09/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableURLRequest (ATCategory)
- (void)setPostData:(NSData *)postData;
@end
