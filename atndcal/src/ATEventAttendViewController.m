//
//  ATEventAttendViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventAttendViewController.h"

#import "ATCommon.h"
#import "ATEventOutlineCell.h"
#import "ATEventForAttend.h"
#import "ATAtndEventDetailViewController.h"
#import "ATSettingMenuViewController.h"


@interface ATEventAttendViewController ()
@property (nonatomic, retain) NSMutableArray *eventArray;

- (void)initATEventAttendViewController;
- (void)requestAtnd:(NSDictionary *)param;
- (void)nextStartRequest:(NSDictionary *)userInfo;
- (void)refleshTable;
- (void)successEventAttendRequest:(NSDictionary *)userInfo;
- (void)errorEventAttendRequest:(NSDictionary *)userInfo;
@end


@implementation ATEventAttendViewController
@synthesize eventArray = _eventArray;

#define countParam 100

static NSString *atndEventSearchUrl = @"http://api.atnd.org/events/";

- (id)init {
    if ((self = [super init])) {
        [self initATEventAttendViewController];
    }
    return self;
}

- (void)initATEventAttendViewController {
    POOL_START;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventAttendRequest:) 
                                                 name:ATNotificationNameEventAttendRequest object:nil];
    
    self.data = [NSArray arrayWithObject:[ATTableData tableData]];
    POOL_END;
}


- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameEventAttendRequest];
    [_eventArray release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    if ([[[_data objectAtIndex:0] rows] count] == 0) {
        [self reloadAction:nil];
    }
}


#pragma mark - Overwride

- (NSString *)titleString {
    return @"参加イベント";
}

- (void)setupCellData {
    POOL_START;
    NSMutableArray *eventArray = [ATEventOutlineManager fetchArrayForAttend];
    
    if (eventArray.count > 0) {
        ATTableData *d = [_data objectAtIndex:0];
        d.rows = eventArray;
    }
    POOL_END;
}

- (void)setupView {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                            target:self 
                                                                                            action:@selector(reloadAction:)] autorelease];
    POOL_END;
}

- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    ATTableData *tableData = [_data objectAtIndex:indexPath.section];
    ATEventOutline *eventOutline = [[tableData rows] objectAtIndex:indexPath.row];
    [(ATEventOutlineCell *)cell setEventOutline:eventOutline];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    POOL_START;
    
    ATTableData *tableData = [_data objectAtIndex:indexPath.section];
    ATEventOutline *outline = [[tableData rows] objectAtIndex:indexPath.row];
    ATAtndEventDetailViewController *ctl = [[[ATAtndEventDetailViewController alloc] 
                                             initWithEventObject:outline.eventObject] autorelease];
    [self.navigationController pushViewController:ctl animated:YES];

    POOL_END;
}

#pragma mark - AtndCallback

- (void)notificationEventAttendRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    LOG(@"statusCode=%d", [statusCode integerValue]);
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successEventAttendRequest:userInfo];
    } else {
        [self errorEventAttendRequest:userInfo];
    }
}

- (void)successEventAttendRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSDictionary *param = [userInfo objectForKey:@"param"];
    
    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];
    
    NSDictionary *dictionary = [ATEventManager dictionaryWithJson:jsonString];
    NSString *results_returned = [dictionary objectForKey:@"results_returned"];
    NSInteger iResultsReturned = [results_returned integerValue];
    
    NSArray *array = [dictionary objectForKey:@"events"];
    [_eventArray addObjectsFromArray:array];
    
    NSInteger iCount = [[param objectForKey:@"count"] integerValue];
    if (iCount > iResultsReturned) {
        [self performSelectorOnMainThread:@selector(finishAtndCallback) withObject:nil waitUntilDone:YES];
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:param forKey:@"param"];
        [self performSelectorOnMainThread:@selector(nextStartRequest:) withObject:userInfo waitUntilDone:YES];
    }
    POOL_END;
}

- (void)errorEventAttendRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;

    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSString *message = [NSString stringWithFormat:@"ATND Server Error\nStatus : %@ \n %@",  
                         [userInfo objectForKey:kATRequestUserInfoStatusCode],
                         [error description]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameEventAttendRequest];

    POOL_END;
}

#pragma mark - Public

- (void)reloadAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsSettingAtndNickname];
    if (nickname && nickname.length > 0) {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
        [param setObject:nickname forKey:@"nickname"];
        [self requestAtnd:param];
    } else {
        ATSettingMenuViewController *ctl = [[[ATSettingMenuViewController alloc] init] autorelease];
        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
        [self presentModalViewController:nav animated:YES];
        
        NSString *message = @"ユーザ名を設定してください.";
        [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    }
    
    POOL_END;
}

#pragma mark - Private

- (void)requestAtnd:(NSDictionary *)param {
    POOL_START;
    
    NSString *start = [param objectForKey:@"start"];
    if (!start) {
        self.eventArray = [NSMutableArray arrayWithCapacity:0];
        
        ATEventForAttendManager *manager = [ATEventForAttendManager sharedATEventForAttendManager];
        [manager truncate];
        [self refleshTable];
    }

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
                                                                 notificationName:ATNotificationNameEventAttendRequest
                                                                          request:request
                                                                         userInfo:userInfo] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];

    POOL_END;
}

- (void)nextStartRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableDictionary *param = [userInfo objectForKey:@"param"];
    NSString *start = [param objectForKey:@"start"];
    NSString *nextStart = [NSString stringWithFormat:@"%d", [start intValue] + countParam];
    
    [param setObject:nextStart forKey:@"start"];
    
    [self requestAtnd:param];
    
    POOL_END;
}

- (void)finishAtndCallback {
    ATEventForAttendManager *manager = [ATEventForAttendManager sharedATEventForAttendManager];
    [manager saveWithEventArray:_eventArray];
    [self refleshTable];
}

- (void)refleshTable {
    POOL_START;
    NSMutableArray *eventArray = [ATEventOutlineManager fetchArrayForAttend];
    [[_data objectAtIndex:0] setRows:eventArray];
    [self.tableView reloadData];
    POOL_END;
}

@end
