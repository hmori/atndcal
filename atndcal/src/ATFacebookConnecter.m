#import "ATFacebookConnecter.h"
#import "ATCommon.h"

#import "ATFbEvent.h"
#import "NetworkActivityIndicator.h"
#import "NSString+SBJSON.h"

@interface ATFacebookConnecter ()
- (void)initATFacebookConnecter;
@property (nonatomic) ATFacebookAuthStatus authStatus;
@property (nonatomic, retain) NSData *meData;
@property (nonatomic) NSUInteger countUpdateMeData;

- (void)autoAuthrize;

@end


@implementation ATFacebookConnecter
@synthesize facebook = _facebook;
@synthesize authStatus = _authStatus;
@synthesize meData = _meData;
@synthesize countUpdateMeData = _countUpdateMeData;

- (id)init {
    LOG_CURRENT_METHOD;
    if ((self = [super init])) {
        [self initATFacebookConnecter];
    }
    return self;
}

- (void)initATFacebookConnecter {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationMeRequest:) 
                                                 name:ATNotificationNameFbMeRequest 
                                               object:nil];
    
    _facebook = [[Facebook alloc] initWithAppId:kAtndcalFacebookAppId 
                                    andDelegate:self];
    [self autoAuthrize];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_facebook release];
    [_meData release];
    [super dealloc];
}

#pragma mark - getter

- (Facebook *)facebook {
    if (!_facebook) {
        [_facebook release];
        _facebook = [[Facebook alloc] initWithAppId:kAtndcalFacebookAppId 
                                        andDelegate:self];
    }
    [self autoAuthrize];
    return _facebook;
}

- (NSData *)meData {
    if (!_meData) {
        _meData = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsFacebookMeData];
    }
    return _meData;
}

#pragma mark - setter

- (void)setMeData:(NSData *)meData {
    if (_meData != meData) {
        [_meData release];
        _meData = [meData retain];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (meData) {
            [defaults setObject:meData forKey:kDefaultsFacebookMeData];
        } else {
            [defaults removeObjectForKey:kDefaultsFacebookMeData];
        }
        [defaults synchronize];
    }
}

#pragma mark - Private

- (void)autoAuthrize {
    static NSString *facebookCookieDomain = @".facebook.com";
    static NSString *facebookCookieName = @"m_user";
    
    BOOL isExistCookie = NO;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([[cookie domain] isEqualToString:facebookCookieDomain] &&
            [[cookie name] isEqualToString:facebookCookieName]) {
            
            LOG(@"cookie=%@", cookie);
            isExistCookie = YES;
        }
    }
    
    if (isExistCookie && ![_facebook isSessionValid] && _authStatus == ATFacebookAuthStatusUnfinished) {
        self.authStatus = ATFacebookAuthStatusProcessing;
        [[NetworkActivityIndicator sharedNetworkActivityIndicator] beginAnimation];
        [_facebook authorizeWithoutDialog:self.facebookPermissions delegate:self];
    }
}

#pragma mark - Public

- (NSDictionary *)dictionaryForMe {
    NSDictionary *dictionary = nil;
    if (self.meData) {
        
        NSString *jsonString = [[[NSString alloc] initWithData:_meData
                                                      encoding:NSUTF8StringEncoding] autorelease];
        id jsonData = [jsonString JSONValue];
        if ([jsonData isKindOfClass:NSDictionary.class]) {
            dictionary = (NSDictionary *)jsonData;
        }
    }
    return dictionary;
}

- (NSArray *)facebookPermissions {
    static NSString *read_stream = @"read_stream";
    static NSString *publish_stream = @"publish_stream";
    static NSString *user_events = @"user_events";
    static NSString *friends_events = @"friends_events";
    static NSString *create_event = @"create_event";
    static NSString *rsvp_event = @"rsvp_event";
    static NSString *offline_access = @"offline_access";
    
    return [NSArray arrayWithObjects:
            read_stream, 
            publish_stream, 
            user_events, 
            friends_events, 
            create_event, 
            rsvp_event, 
            offline_access, nil];
}

- (void)notificationMeRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
#if DEBUG
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    LOG(@"error=%@", [error localizedDescription]);
    LOG(@"statusCode=%d", [statusCode intValue]);
#endif
    
    self.meData = [userInfo objectForKey:kATRequestUserInfoReceivedData];
    self.countUpdateMeData += 1;
}

- (NSURLRequest *)requestWithObjectId:(NSString *)objectId {
    static NSString *httpMethod = @"GET";

    FBRequest *fbRequest = [self.facebook requestWithGraphPath:objectId 
                                                     andParams:[NSMutableDictionary dictionary] 
                                                 andHttpMethod:httpMethod 
                                                   andDelegate:self];
    return [fbRequest getURLRequest];
}

- (NSURLRequest *)requestEventListForMe {
    static NSString *vQuery = @"SELECT eid,name,tagline,nid,pic_small,pic_big,pic_square,pic,host,description,event_type,event_subtype,start_time	,end_time,creator,update_time,location,venue,privacy,hide_guest_list,can_invite_friends FROM event WHERE eid in (select eid from event_member where uid = me());";
    static NSString *kQuery = @"query";
    static NSString *vDateFormat = @"U";
    static NSString *kDateFormat = @"date_format";
    static NSString *methodName = @"fql.query";
    static NSString *httpMethod = @"POST";
    
    NSMutableDictionary *params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     vQuery, kQuery,
     vDateFormat, kDateFormat,
     nil];
    FBRequest *fbRequest = [self.facebook requestWithMethodName:methodName
                                                      andParams:params
                                                  andHttpMethod:httpMethod
                                                    andDelegate:self];
    return [fbRequest getURLRequest];
}

- (NSURLRequest *)requestSelectRsvpStatusOfEventId:(NSString *)eventId {
    static NSString *queryFormat = @"select eid, uid, rsvp_status from event_member where uid = me() and eid = %@;";
    static NSString *kQuery = @"query";
    static NSString *vDateFormat = @"U";
    static NSString *kDateFormat = @"date_format";
    static NSString *methodName = @"fql.query";
    static NSString *httpMethod = @"POST";

    NSString *query = [NSString stringWithFormat:queryFormat, eventId];
    
    NSMutableDictionary * params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     query, kQuery,
     vDateFormat, kDateFormat,
     nil];
    FBRequest *fbRequest = [self.facebook requestWithMethodName:methodName
                                                      andParams:params
                                                  andHttpMethod:httpMethod
                                                    andDelegate:self];
    return [fbRequest getURLRequest];
}

- (NSURLRequest *)requestUpdateRsvpStatus:(ATFacebookRsvpStatus)status eventId:(NSString *)eventId {
    
    static NSString *attending = @"attending";
    static NSString *maybe = @"maybe";
    static NSString *declined = @"declined";
    static NSString *httpMethod = @"POST";
    static NSString *graphPathFormat = @"%@/%@";
    
    NSString *command = nil;
    if (status == ATFacebookRsvpStatusAttending) {
        command = attending;
    } else if (status == ATFacebookRsvpStatusMaybe) {
        command = maybe;
    } else if (status == ATFacebookRsvpStatusDeclined) {
        command = declined;
    }
    
    FBRequest *fbRequest = [self.facebook requestWithGraphPath:[NSString stringWithFormat:graphPathFormat, eventId, command]
                                                     andParams:[NSMutableDictionary dictionary] 
                                                 andHttpMethod:httpMethod 
                                                   andDelegate:self];
    return [fbRequest getURLRequest];
}


#pragma mark - FBSessionDelegate

- (void)fbDidLogin {
    LOG_CURRENT_METHOD;
    [[NetworkActivityIndicator sharedNetworkActivityIndicator] stopAnimation];
    
    if ([_facebook isSessionValid]) {
        static NSString *graphPathMe = @"me";
        
        self.authStatus = ATFacebookAuthStatusSuccessed;

        FBRequest *fbRequest = [_facebook requestWithGraphPath:graphPathMe andDelegate:self];
        NSURLRequest *request = [fbRequest getURLRequest];
        ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                     notificationName:ATNotificationNameFbMeRequest 
                                                                              request:request] autorelease];
        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        [[ATOperationManager sharedATOperationManager] addOperation:operation];
    } else {
        self.authStatus = ATFacebookAuthStatusUnfinished;
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    LOG_CURRENT_METHOD;
    [[NetworkActivityIndicator sharedNetworkActivityIndicator] stopAnimation];
    self.authStatus = ATFacebookAuthStatusUnfinished;
    self.meData = nil;
    self.countUpdateMeData += 1;
}

- (void)fbDidLogout {
    LOG_CURRENT_METHOD;
    self.authStatus = ATFacebookAuthStatusUnfinished;
    self.meData = nil;
    self.countUpdateMeData += 1;
}

#pragma mark - FBRequestDelegate
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    LOG_CURRENT_METHOD;
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    LOG_CURRENT_METHOD;
    LOG(@"result=%@", [result description]);
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    LOG_CURRENT_METHOD;
}

@end


@implementation Facebook (Additions)

static NSString* kDialogBaseURL = @"https://m.facebook.com/dialog/";
static NSString* kRedirectURL = @"fbconnect://success";
static NSString* kLogin = @"oauth";
static NSString* kSDKVersion = @"2";

- (void)authorizeWithoutDialog:(NSArray *)permissions delegate:(id<FBSessionDelegate>)delegate {
    LOG_CURRENT_METHOD;
    
    if (![self isSessionValid]) {
        
        [_permissions release];
        _permissions = [permissions retain];
        
        _sessionDelegate = delegate;
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       _appId, @"client_id",
                                       @"user_agent", @"type",
                                       kRedirectURL, @"redirect_uri",
                                       @"touch", @"display",
                                       kSDKVersion, @"sdk",
                                       nil];
        
        NSString *loginDialogURL = [kDialogBaseURL stringByAppendingString:kLogin];
        if (_permissions != nil) {
            NSString* scope = [_permissions componentsJoinedByString:@","];
            [params setValue:scope forKey:@"scope"];
        }
        
        [_loginDialog release];
        _loginDialog = [[FBLoginDialog alloc] initWithURL:loginDialogURL
                                              loginParams:params
                                                 delegate:self];
        [_loginDialog load];
    }
}


@end

@implementation FBRequest (Additions)

static NSString* kUserAgent = @"FacebookConnect";
static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
static const int kGeneralErrorCode = 10000;

static const NSTimeInterval kTimeoutInterval = 180.0;

- (NSURLRequest *)getURLRequest {
    
    static NSString *UserAgentFieldName = @"User-Agent";
    static NSString *httpMethod = @"POST";
    static NSString *contentTypeFormat = @"multipart/form-data; boundary=%@";
    static NSString *contentTypeFieldName = @"Content-Type";
    
    NSString *url = [[self class] serializeURL:_url params:_params httpMethod:_httpMethod];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:kTimeoutInterval];
    [request setValue:kUserAgent forHTTPHeaderField:UserAgentFieldName];
    
    
    [request setHTTPMethod:self.httpMethod];
    if ([self.httpMethod isEqualToString:httpMethod]) {
        NSString *contentType = [NSString
                                 stringWithFormat:contentTypeFormat, kStringBoundary];
        [request setValue:contentType forHTTPHeaderField:contentTypeFieldName];
        
        [request setHTTPBody:[self performSelector:@selector(generatePostBody)]];
    }
    return request;
}

@end