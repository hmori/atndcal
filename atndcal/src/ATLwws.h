//
//  ATLwws.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATLwws;

@interface ATLwwsManager : NSObject {

}
+ (ATLwwsManager *)sharedATLwwsManager;
+ (NSString *)stringForDispDescription:(ATLwws *)lwws;

@end


@interface ATLwws : NSObject {
  @private
    NSString *_title;
    NSString *_link;
    NSString *_telop;
    NSString *_description_;
    NSString *_imageUrl;
    NSString *_maxCelsius;
    NSString *_minCelsius;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *telop;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *maxCelsius;
@property (nonatomic, copy) NSString *minCelsius;

@end
