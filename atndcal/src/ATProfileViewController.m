//
//  ATProfileViewController.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATProfileViewController.h"
#import "ATCommon.h"

#import "ATProfileLabelView.h"

#import "ATUser.h"
#import "ATEventOutlineGroupedCell.h"

#import "ATWebViewController.h"
#import "ATAtndEventDetailViewController.h"

@interface ATProfileViewController ()
@property (nonatomic, copy) NSString *twitterId;
- (void)initATProfileViewController;
- (void)requestAtndUsers:(NSDictionary *)param;
- (void)successProfileUserRequest:(NSDictionary *)userInfo;
- (void)errorProfileUserRequest:(NSDictionary *)userInfo;
- (void)requestAtndEvents:(NSDictionary *)param;
- (void)successEventsRequest:(NSDictionary *)userInfo;
- (void)errorEventsRequest:(NSDictionary *)userInfo;
@end


@implementation ATProfileViewController
@synthesize userId = _userId;
@synthesize twitterId = _twitterId;
@synthesize ownerEventsArray = _ownerEventsArray;
@synthesize userEventsArray = _userEventsArray;

#define countParam 5
static NSString *atndUserSearchUrl = @"http://api.atnd.org/events/users/";
static NSString *atndEventSearchUrl = @"http://api.atnd.org/events/";


- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATProfileViewController];
    }
    return self;
}

- (void)initATProfileViewController {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationProfileUserRequest:) 
                                                 name:ATNotificationNameProfileUserRequest 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationEventsRequest:) 
                                                 name:ATNotificationNameEventsRequest 
                                               object:nil];
    

    
    _profileLabelView = [[ATProfileLabelView alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_userId release];
    [_twitterId release];
    [_ownerEventsArray release];
    [_userEventsArray release];
    [_profileLabelView release];
    [super dealloc];
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    
    [self reloadAction:nil];
}

#pragma mark - Overwride

- (NSString *)titleString {
    return @"プロフィール";
}

- (void)setupView {
    POOL_START;
    
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"閉じる" 
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:self 
                                                                                 action:@selector(closeAction:)] autorelease];
    }
    UIView *spaceView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)] autorelease];
    UIBarButtonItem *fixedItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceView] autorelease];
    self.navigationItem.rightBarButtonItem = fixedItem;
    
    POOL_END;
}

- (void)setupCellData {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
	
    d = [ATTableData tableData];
    d.rows = [NSArray arrayWithObjects:@"Twitter", nil];
	[tmp addObject:d];
    
    d = [ATTableData tableData];
    d.title = @"管理イベント";
	[tmp addObject:d];
    
    d = [ATTableData tableData];
    d.title = @"参加イベント";
	[tmp addObject:d];
    
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    POOL_END;
}


#pragma mark - UITableViewDelegate && Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = tableView.rowHeight;
    if (section == 0) {
        height = 90;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if (section == 0) {
        view = _profileLabelView;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = tableView.rowHeight;
    if (indexPath.section == 1 || indexPath.section == 2) {
        height = [ATEventOutlineGroupedCell heightCell];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *Value1Cell = @"Value1Cell";
    static NSString *EventOutlineGroupedCell = @"EventOutlineGroupedCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:Value1Cell];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                           reuseIdentifier:Value1Cell] autorelease];
        }
        cell = [self setupCellForRowAtIndexPath:indexPath cell:cell];
    } else if (indexPath.section == 1 || indexPath.section == 2) {
        cell = (ATEventOutlineGroupedCell *)[tableView dequeueReusableCellWithIdentifier:EventOutlineGroupedCell];
        if (cell == nil) {
            cell = [[[ATEventOutlineGroupedCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                              reuseIdentifier:EventOutlineGroupedCell] autorelease];
        }
        ATTableData *tableData = [_data objectAtIndex:indexPath.section];
        ATEventOutline *eventOutline = [[tableData rows] objectAtIndex:indexPath.row];
        [(ATEventOutlineGroupedCell *)cell setEventOutline:eventOutline];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    
    if (indexPath.section == 0) {
        if (_twitterId) {
            NSString *twitterUrlFormat = @"http://twitter.com/#!/%@";
            NSString *urlString = [NSString stringWithFormat:twitterUrlFormat, _twitterId];
            ATWebViewController *ctl = [[[ATWebViewController alloc] initWithUrlString:urlString] autorelease];
            [self.navigationController pushViewController:ctl animated:YES];
        }
    } else if (indexPath.section == 1 || indexPath.section == 2) {
        ATTableData *tableData = [_data objectAtIndex:indexPath.section];
        ATEventOutline *eventOutline = [[tableData rows] objectAtIndex:indexPath.row];
        
        ATAtndEventDetailViewController *ctl = [[[ATAtndEventDetailViewController alloc] initWithEventObject:eventOutline.eventObject] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

#pragma mark - Private

#pragma mark - Public

- (void)reloadAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:_userId forKey:@"user_id"];
    [self requestAtndUsers:param];
    
    param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:_userId forKey:@"owner_id"];
    [self requestAtndEvents:param];
    
    param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:_userId forKey:@"user_id"];
    [self requestAtndEvents:param];
    
    POOL_END;
}

#pragma mark - Private

#pragma mark AtndUsersRequest

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
                                                                 notificationName:ATNotificationNameProfileUserRequest 
                                                                          request:request
                                                                         userInfo:userInfo] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}


- (void)notificationProfileUserRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successProfileUserRequest:userInfo];
    } else {
        [self errorProfileUserRequest:userInfo];
    }
    
    [_profileLabelView stopIndicator];
}

- (void)successProfileUserRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];
    
    NSDictionary *dictionary = [ATUserManager dictionaryWithJson:jsonString];
    NSArray *newUserArray = [dictionary objectForKey:@"users"];
    
    for (id userObj in newUserArray) {
        ATUser *user = [ATUserManager userWithDictionary:userObj];
        
        if ([user.user_id isEqual:_userId]) {
            _profileLabelView.label.text = user.nickname;
            
            if (user.twitter_id && (NSNull *)user.twitter_id != [NSNull null]) {
                self.twitterId = user.twitter_id;
                ATTableData *tableData = [self.data objectAtIndex:0];
                tableData.detailRows = [NSArray arrayWithObject:user.twitter_id];
                tableData.accessorys = [NSArray arrayWithObject:[NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator]];
                [self.tableView reloadData];
            }
            if (user.twitter_img && (NSNull *)user.twitter_img != [NSNull null] ) {
                _profileLabelView.imageUrl = user.twitter_img;
            } else {
                _profileLabelView.imageView.image = [[ATResource sharedATResource] imageOfPath:@"TapkuLibrary.bundle/Images/empty/malePerson.png"];
            }
            break;
        }
    }
    POOL_END;
}

- (void)errorProfileUserRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *message = [NSString stringWithFormat:@"ATND Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAttendeeUsersRequest];
    
    POOL_END;
}


#pragma mark AtndEventsRequest

- (void)requestAtndEvents:(NSDictionary *)param {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableDictionary *requestParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [requestParam setObject:@"json" forKey:@"format"];
    [requestParam setObject:[NSString stringWithFormat:@"%d", countParam] forKey:@"count"];
    
    NSString *paramString = [NSString stringForURLParam:requestParam method:@"GET"];
    NSString *url = [NSString stringWithFormat:@"%@%@", atndEventSearchUrl, paramString];
    
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:requestParam forKey:@"param"];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameEventsRequest 
                                                                          request:request
                                                                         userInfo:userInfo] 
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}

- (void)notificationEventsRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;

    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successEventsRequest:userInfo];
    } else {
        [self errorEventsRequest:userInfo];
    }
}

- (void)successEventsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];
    LOG(@"jsonString=%@", jsonString);
    
    NSDictionary *param = [userInfo objectForKey:@"param"];
    LOG(@"param=%@", [param description]);
    
    NSDictionary *dictionary = [ATEventManager dictionaryWithJson:jsonString];
    id events = [dictionary objectForKey:@"events"];
    NSMutableArray *array = [ATEventOutlineManager arrayForEventObjects:events];

    id owner_id = [param objectForKey:@"owner_id"];
    id user_id = [param objectForKey:@"user_id"];
    if (owner_id && (NSNull *)owner_id != [NSNull null]) {
        ATTableData *tableData = [self.data objectAtIndex:1];
        tableData.rows = array;
    } else if (user_id && (NSNull *)user_id != [NSNull null]) {
        ATTableData *tableData = [self.data objectAtIndex:2];
        tableData.rows = array;
    }
    [self.tableView reloadData];
    
    POOL_END;
}

- (void)errorEventsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *message = [NSString stringWithFormat:@"ATND Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAttendeeUsersRequest];
    
    POOL_END;
}



@end
