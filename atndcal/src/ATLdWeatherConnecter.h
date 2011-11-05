//
//  ATLdWeatherConnecter.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/11/01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRssLdWeather.h"

@interface ATLdWeatherConnecter : NSObject {
    NSMutableArray *_forecasts;
}
+ (ATLdWeatherConnecter *)sharedATLdWeatherConnecter;

@property (nonatomic, retain) NSMutableArray *forecasts;

- (void)forecastConnect;

@end
