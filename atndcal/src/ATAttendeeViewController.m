#import "ATAttendeeViewController.h"
#import "ATCommon.h"

#import "ATUser.h"
#import "NSString+SBJSON.h"

#import "ATProfileViewController.h"

@interface ATAttendeeViewController ()
@property (nonatomic, retain) NSMutableArray *userArray;
@property (nonatomic, retain) NSMutableDictionary *twitterImageUrlDictionary;

- (void)initATAttendeeViewController;
- (void)refreshCellData;
- (void)requestAtndUsers:(NSDictionary *)param;
- (void)successAttendeeUsersRequest:(NSDictionary *)userInfo;
- (void)errorAttendeeUsersRequest:(NSDictionary *)userInfo;
- (void)successAttendeeTwitterUsersRequest:(NSDictionary *)userInfo;
- (void)errorAttendeeTwitterUsersRequest:(NSDictionary *)userInfo;
@end


@implementation ATAttendeeViewController

@synthesize event = _event;
@synthesize userArray = _userArray;
@synthesize twitterImageUrlDictionary = _twitterImageUrlDictionary;

#define countParam 100
static NSString *atndUserSearchUrl = @"http://api.atnd.org/events/users/";
static NSString *twitterUsersLookupUrl = @"http://api.twitter.com/1/users/lookup.json";

- (id)init {
    if ((self = [super init])) {
        [self initATAttendeeViewController];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATAttendeeViewController];
    }
    return self;
}

- (void)initATAttendeeViewController {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAttendeeUsersRequest:) 
                                                 name:ATNotificationNameAttendeeUsersRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAttendeeTwitterUsersRequest:) 
                                                 name:ATNotificationNameAttendeeTwitterUsersRequest object:nil];
    
    self.userArray = [NSMutableArray arrayWithCapacity:0];
    self.twitterImageUrlDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    POOL_END;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAttendeeUsersRequest];
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAttendeeTwitterUsersRequest];

    [_event release];
    [_userArray release];
    [_twitterImageUrlDictionary release];
    [super dealloc];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    
    [self reloadAction:nil];
}

#pragma mark - Overwride

- (NSString *)titleString {
    return _event.title;
}

- (void)setupCellData {
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;

    if (indexPath.row < _userArray.count) {
        ATUser *user = [ATUserManager userWithDictionary:[_userArray objectAtIndex:indexPath.row]];

        ATProfileViewController *ctl = [[[ATProfileViewController alloc] init] autorelease];
        ctl.userId = user.user_id;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}


#pragma mark - Public

- (void)reloadAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:_event.event_id forKey:@"event_id"];
    [self requestAtndUsers:param];

    POOL_END;
}

#pragma mark -Private

- (void)refreshCellData {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableArray *attendRows = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *attendImageUrls = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *attendAccessorys = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *waitingRows = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *waitingImageUrls = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *waitingAccessorys = [NSMutableArray arrayWithCapacity:0];
    
    for (id u in _userArray) {
        ATUser *user = [ATUserManager userWithDictionary:u];
        NSString *nickname = (user.nickname?user.nickname:(NSString *)[NSNull null]);
        NSString *imageUrl = ([_twitterImageUrlDictionary objectForKey:user.twitter_id]?
                              [_twitterImageUrlDictionary objectForKey:user.twitter_id]:
                              TKBUNDLE(@"TapkuLibrary.bundle/Images/empty/malePerson.png"));
        if ([user.status boolValue]) {
            [attendRows addObject:nickname];
            [attendImageUrls addObject:imageUrl];
            [attendAccessorys addObject:[NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator]];
        } else {
            [waitingRows addObject:nickname];
            [waitingImageUrls addObject:imageUrl];
            [waitingAccessorys addObject:[NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator]];
        }
    }
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
	
    d = [ATTableData tableData];
    d.title = @"参加者";
    d.rows = attendRows;
    d.imageUrls = attendImageUrls;
    d.accessorys = attendAccessorys;
    [tmp addObject:d];
    
    if (waitingRows.count > 0) {
        d = [ATTableData tableData];
        d.title = @"補欠者";
        d.rows = waitingRows;
        d.imageUrls = waitingImageUrls;
        d.accessorys = waitingAccessorys;
        [tmp addObject:d];
    }
    
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    [self.tableView reloadData];
    POOL_END;
}

- (void)requestAtndUsers:(NSDictionary *)param {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableDictionary *requestParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [requestParam setObject:@"json" forKey:@"format"];
    [requestParam setObject:[NSString stringWithFormat:@"%d", countParam] forKey:@"count"];
    
    NSString *paramString = [NSString stringForURLParam:requestParam method:@"GET"];
    NSString *url = [NSString stringWithFormat:@"%@%@", atndUserSearchUrl, paramString];
    
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:requestParam forKey:@"param"];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameAttendeeUsersRequest 
                                                                          request:request
                                                                         userInfo:userInfo] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}


- (void)requestTwitterUsersLookup:(NSDictionary *)param {
    LOG_CURRENT_METHOD;
    POOL_START;

    NSString *paramString = [NSString stringForURLParam:param method:@"GET"];
    NSString *url = [NSString stringWithFormat:@"%@%@", twitterUsersLookupUrl, paramString];
    
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:param forKey:@"param"];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameAttendeeTwitterUsersRequest
                                                                          request:request
                                                                         userInfo:userInfo] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}

- (NSString *)commaScreenNamesWithUserArray:(NSArray *)userArray {
    NSMutableString *screen_name = [NSMutableString stringWithCapacity:0];
    for (id u in userArray) {
        POOL_START;
        ATUser *user = [ATUserManager userWithDictionary:u];
        if (screen_name.length > 0) {
            [screen_name appendString:@","];
        }
        if (user.twitter_id && (NSNull *)user.twitter_id != [NSNull null]) {
            [screen_name appendString:user.twitter_id];
        }
        POOL_END;
    }
    return screen_name;
}

#pragma mark - AtndRequest Callback

- (void)notificationAttendeeUsersRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successAttendeeUsersRequest:userInfo];
    } else {
        [self errorAttendeeUsersRequest:userInfo];
    }

}

- (void)successAttendeeUsersRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];

    NSDictionary *dictionary = [ATUserManager dictionaryWithJson:jsonString];
    NSArray *newUserArray = [dictionary objectForKey:@"users"];
    
    [_userArray addObjectsFromArray:newUserArray];

    NSString *screen_name = [self commaScreenNamesWithUserArray:newUserArray];
    if (screen_name.length > 0) {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
        [param setObject:screen_name forKey:@"screen_name"];
        [self requestTwitterUsersLookup:param];
    } else {
        [self refreshCellData];
    }
    POOL_END;
}

- (void)errorAttendeeUsersRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *message = [NSString stringWithFormat:@"ATND Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];

    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAttendeeUsersRequest];
    
    POOL_END;
}

#pragma mark - TwitterRequest Callback

- (void)notificationAttendeeTwitterUsersRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successAttendeeTwitterUsersRequest:userInfo];
    } else {
        [self errorAttendeeTwitterUsersRequest:userInfo];
    }
}


- (void)successAttendeeTwitterUsersRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];
    id jsonData = [jsonString JSONValue];
    if ([jsonData isKindOfClass:NSArray.class]) {
        for (id u in jsonData) {
            NSString *screen_name = [u objectForKey:@"screen_name"];
            NSString *profile_image_url = [u objectForKey:@"profile_image_url"];
            [_twitterImageUrlDictionary setObject:profile_image_url forKey:screen_name];
        }
    }
    [self refreshCellData];
    
    POOL_END;
}

- (void)errorAttendeeTwitterUsersRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *message = [NSString stringWithFormat:@"Twitter Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAttendeeTwitterUsersRequest];
    
    POOL_END;
}

@end
