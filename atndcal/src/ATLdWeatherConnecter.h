#import <Foundation/Foundation.h>
#import "ATRssLdWeather.h"

@interface ATLdWeatherConnecter : NSObject {
    NSMutableArray *_forecasts;
}
+ (ATLdWeatherConnecter *)sharedATLdWeatherConnecter;

@property (nonatomic, retain) NSMutableArray *forecasts;

- (void)forecastConnect;

@end
