#import "ATFbEventStatusViewController.h"

#import "ATCommon.h"

@interface ATFbEventStatusViewController ()
@property NSInteger selectedIndex;

- (void)initATFbEventStatusViewController;
- (void)sendUpdateRsvpStatus:(ATFacebookRsvpStatus)status;
- (void)successFbUpdateRsvpStatusRequest:(NSDictionary *)userInfo;
- (void)errorFbUpdateRsvpStatusRequest:(NSDictionary *)userInfo;
@end


@implementation ATFbEventStatusViewController
@synthesize eventStatus = _eventStatus;
@synthesize selectedIndex = _selectedIndex;

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATFbEventStatusViewController];
    }
    return self;
}

- (void)initATFbEventStatusViewController {
    _selectedIndex = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationFbUpdateRsvpStatusRequest:) 
                                                 name:ATNotificationNameFbUpdateRsvpStatusRequest 
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_eventStatus release];
    [super dealloc];
}

#pragma mark - setter

- (void)setEventStatus:(ATFbEventStatus *)eventStatus {
    if (_eventStatus != eventStatus) {
        [_eventStatus release];
        _eventStatus = [eventStatus retain];
        _selectedIndex = eventStatus.status;
    }
}

#pragma mark - Overwride methods

- (NSString *)titleString {
    return @"出欠の返事";
}

- (void)setupCellData {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
	
    d = [ATTableData tableData];
    d.rows = [ATFbEventStatusManager arrayDispForStatusSelect];
    d.footer = nil;
	[tmp addObject:d];
	
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    POOL_END;
}

- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    LOG_CURRENT_METHOD;
    [super setupCellForRowAtIndexPath:indexPath cell:cell];
    
    if (indexPath.row == _selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;

    _selectedIndex = indexPath.row;
    [self.tableView reloadData];
    
    ATFacebookRsvpStatus status = ATFacebookRsvpStatusNoreply;
    if (indexPath.row == 0) {
        status = ATFacebookRsvpStatusAttending;
    } else if (indexPath.row == 1) {
        status = ATFacebookRsvpStatusMaybe;
    } else if (indexPath.row == 2) {
        status = ATFacebookRsvpStatusDeclined;
    }
    [self sendUpdateRsvpStatus:status];
    
    _eventStatus.status = status;
}

#pragma mark - Private 

- (void)sendUpdateRsvpStatus:(ATFacebookRsvpStatus)status {
    POOL_START;
    
    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    NSURLRequest *request = [fbConnecter requestUpdateRsvpStatus:status eventId:_eventStatus.eid];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameFbUpdateRsvpStatusRequest
                                                                          request:request] 
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}


#pragma mark - FacebookRequest Callback

- (void)notificationFbUpdateRsvpStatusRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successFbUpdateRsvpStatusRequest:userInfo];
    } else {
        [self errorFbUpdateRsvpStatusRequest:userInfo];
    }
}

- (void)successFbUpdateRsvpStatusRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
}

- (void)errorFbUpdateRsvpStatusRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSString *message = [NSString stringWithFormat:@"Facebook ServerError\nStatus : %@ \n %@",  
                         [userInfo objectForKey:kATRequestUserInfoStatusCode],
                         [error localizedDescription]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];

    POOL_END;
}


@end