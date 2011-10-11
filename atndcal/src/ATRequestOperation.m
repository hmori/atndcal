//
//  ATRequestOperation.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATRequestOperation.h"
#import "NetworkActivityIndicator.h"

NSString * const ATNotificationNameNoticeInfoRequest = @"ATNotificationNameNoticeInfoRequest";

NSString * const ATNotificationNameCalendarEventsRequest = @"ATNotificationNameCalendarEventsRequest";
NSString * const ATNotificationNameAttendeeUsersRequest = @"ATNotificationNameAttendeeUsersRequest";
NSString * const ATNotificationNameAttendeeTwitterUsersRequest = @"ATNotificationNameAttendeeTwitterUsersRequest";
NSString * const ATNotificationNameEventAttendRequest = @"ATNotificationNameEventAttendRequest";
NSString * const ATNotificationNameEventCommentRequest = @"ATNotificationNameEventCommentRequest";
NSString * const ATNotificationNameFbMeRequest = @"ATNotificationNameFbMeRequest";
NSString * const ATNotificationNameFbEventsRequest = @"ATNotificationNameFbEventsRequest";
NSString * const ATNotificationNameFbEventDetailRequest = @"ATNotificationNameFbEventDetailRequest";
NSString * const ATNotificationNameFbRsvpStatusRequest = @"ATNotificationNameFbRsvpStatusRequest";
NSString * const ATNotificationNameFbUpdateRsvpStatusRequest = @"ATNotificationNameFbUpdateRsvpStatusRequest";
NSString * const ATNotificationNameAnalysisRequest = @"ATNotificationNameAnalysisRequest";
NSString * const ATNotificationNameProfileUserRequest = @"ATNotificationNameProfileUserRequest";
NSString * const ATNotificationNameEventsRequest = @"ATNotificationNameEventsRequest";

NSString * const kATRequestUserInfoStatusCode = @"kATRequestUserInfoStatusCode";
NSString * const kATRequestUserInfoReceivedData = @"kATRequestUserInfoReceivedData";
NSString * const kATRequestUserInfoError = @"kATRequestUserInfoError";


@interface ATRequestOperation ()
@property (nonatomic, retain) NSMutableDictionary *userInfo;
@property (nonatomic, retain) NSURLRequest *request;
- (void)initATRequestOperation;
- (void)abort;
- (void)finishLoading;
- (void)notify;
@end


@implementation ATRequestOperation

@synthesize delegate = _delegate;
@synthesize notificationName = _notificationName;
@synthesize userInfo = _userInfo;
@synthesize request = _request;
@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

static NSString * const kIsExecuting = @"isExecuting";
static NSString * const kIsFinished = @"isFinished";

- (id)initWithDelegate:(id)delegate 
      notificationName:(NSString *)aName 
               request:(NSURLRequest *)request {
    LOG_CURRENT_METHOD;
    return [self initWithDelegate:delegate 
                 notificationName:aName 
                          request:request 
                         userInfo:[NSMutableDictionary dictionaryWithCapacity:0]];
}

- (id)initWithDelegate:(id)delegate 
      notificationName:(NSString *)aName 
               request:(NSURLRequest *)request 
              userInfo:(NSMutableDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    if ((self = [super init])) {
        self.delegate = delegate;
        self.notificationName = aName;
        self.request = request;
        self.userInfo = userInfo;
        [self initATRequestOperation];
    }
    return self;
}

- (void)initATRequestOperation {
    LOG_CURRENT_METHOD;
    _receivedData = [[NSMutableData alloc] initWithCapacity:0];
}

- (void)dealloc {
//    LOG_CURRENT_METHOD;
    [_notificationName release];
    [_userInfo release];
	[super dealloc];
}

#pragma mark - Private

- (void)abort {
    LOG_CURRENT_METHOD;
    
    [[NetworkActivityIndicator sharedNetworkActivityIndicator] stopAnimation];
    
    [self setValue:[NSNumber numberWithBool:NO] forKey:kIsExecuting];
    [self setValue:[NSNumber numberWithBool:YES] forKey:kIsFinished];

	if(_connection != nil){
		[_connection cancel];
		[_connection release]; _connection = nil;
	}
    if (_request != nil) {
        [_request release]; _request = nil;
    }
	if(_response != nil){
		[_response release]; _response = nil;
	}
	if(_receivedData != nil){
		[_receivedData release]; _receivedData = nil;
	}
    
}

- (void)finishLoading {
    LOG_CURRENT_METHOD;
    if (![self isCancelled]) {
        if ([_response isKindOfClass:NSHTTPURLResponse.class]) {
            [_userInfo setObject:[NSNumber numberWithInteger:[(NSHTTPURLResponse *)_response statusCode]] forKey:kATRequestUserInfoStatusCode];
            [_userInfo setObject:_receivedData forKey:kATRequestUserInfoReceivedData];
        }
        [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:YES];
    }
    [self abort];
}

- (void)notify {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self userInfo:_userInfo];
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	LOG_CURRENT_METHOD;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_receivedData setLength:0];
	_response = [response retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	LOG_CURRENT_METHOD;
    if (error) {
        [_userInfo setObject:error forKey:kATRequestUserInfoError];
    }
    [self finishLoading];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    LOG_CURRENT_METHOD;
    [self finishLoading];
}

#pragma mark - Overwride NSOperation

- (BOOL)isConcurrent {
    LOG_CURRENT_METHOD;
    return YES;
}

- (void)start {
    LOG_CURRENT_METHOD;

    POOL_START;
    if (![self isCancelled]) {
        
        [[NetworkActivityIndicator sharedNetworkActivityIndicator] beginAnimation];
        
        [self setValue:[NSNumber numberWithBool:YES] forKey:kIsExecuting];
        LOG(@"Request URL=%@", _request.URL.absoluteString);
        
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        if (_connection != nil) {
            // iOS4以降、NSURLConnection は RunLoop をまわさないと並列実行モードで動かない
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate distantFuture]];
            } while (self.isExecuting);
        }
    }
    
    POOL_END;
}


@end
