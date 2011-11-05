//
//  ATRssLdWeather.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATRssLdWeather : NSObject {
  @private
    NSString *_title;
    NSString *_id_;
    NSString *_source;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *source;

@end
