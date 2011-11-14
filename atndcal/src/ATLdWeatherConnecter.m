#import "ATLdWeatherConnecter.h"
#import "ObjectSingleton.h"
#import "ATCommon.h"

#import "ATLdWeatherRssParser.h"


@interface ATLdWeatherConnecter ()
- (void)successLdWeatherForecastRequest:(NSDictionary *)userInfo;
- (void)errorLdWeatherForecastRequest:(NSDictionary *)userInfo;
@end



@implementation ATLdWeatherConnecter

OBJECT_SINGLETON_TEMPLATE(ATLdWeatherConnecter, sharedATLdWeatherConnecter)

@synthesize forecasts = _forecasts;

static NSString *forecastUrl = @"http://weather.livedoor.com/forecast/rss/forecastmap.xml";


- (void)dealloc {
    [_forecasts release];
    [super dealloc];
}

#pragma mark - Public

- (void)forecastConnect {
    LOG_CURRENT_METHOD;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationNameLdWeatherForecastRequest:) 
                                                 name:ATNotificationNameLdWeatherForecastRequest 
                                               object:nil];

    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:forecastUrl] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameLdWeatherForecastRequest
                                                                          request:request]
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
}


#pragma mark - Forecast Request Callback

- (void)notificationNameLdWeatherForecastRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ATNotificationNameLdWeatherForecastRequest 
                                                  object:nil];

    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successLdWeatherForecastRequest:userInfo];
    } else {
        [self errorLdWeatherForecastRequest:userInfo];
    }
}

- (void)successLdWeatherForecastRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    
    NSData *receivedData = [userInfo objectForKey:kATRequestUserInfoReceivedData];
    
    ATLdWeatherRssParser *ldWeatherRssParser = [[[ATLdWeatherRssParser alloc] init] autorelease];
    [ldWeatherRssParser parse:receivedData];
    
    self.forecasts = ldWeatherRssParser.ldWeathers;
}

- (void)errorLdWeatherForecastRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSString *message = [NSString stringWithFormat:@"Forecast Error\nStatus : %@ \n %@",  
                         [userInfo objectForKey:kATRequestUserInfoStatusCode],
                         [error localizedDescription]];
    LOG(@"error=%@", message);
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameLdWeatherForecastRequest];
}



@end
