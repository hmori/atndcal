//
//  ATResource.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATResource : NSObject {
  @private
    NSMutableDictionary *_resouceDictionary;
}
+ (ATResource *)sharedATResource;

- (UIImage *)imageOfPath:(NSString *)path;

@end
