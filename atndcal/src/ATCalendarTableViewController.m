#import "ATCalendarTableViewController.h"
#import "ATCommon.h"

#import "ATEventForDate.h"
#import "ATEventOutlineCell.h"
#import "ATKeywordHistory.h"
#import "ATAtndEventDetailViewController.h"
#import "ATFbEventDetailViewController.h"
#import "ATMenuViewController.h"



@interface ATCalendarTableViewController ()

@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;
@property (nonatomic, retain) NSMutableArray *eventArray;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *lastDate;
@property (nonatomic, retain) ATCalendarTitleView *titleView;
@property (nonatomic, retain) UIImageView *shadowView;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *keyword_or;

- (void)initATCalendarTableViewController;

- (void)clearSavedEventData;
- (void)setupLoadTerm:(NSDate *)startDate;
- (void)refleshRightBarButton;
- (NSArray *)arrayForCustomRightBarButton;
- (void)zoomAnimation;
- (void)reloadAtnd:(id)sender;
- (void)reloadFacebook:(id)sender;
- (void)requestAtnd:(NSDictionary *)param;
- (void)requestFacebook:(id)sender;
- (void)nextStartRequest:(NSDictionary *)userInfo;
- (void)nextDayRequest:(NSDictionary *)userInfo;
- (void)refleshCalenderOfDate:(NSDate *)date eventArray:(NSArray *)eventArray type:(ATEventType)type;
- (void)refleshCalenderWithSelectDate:(NSDate *)date;
- (void)setupKeyword:(NSString *)text;

- (void)errorCalendarEventsRequest:(NSDictionary *)userInfo;
- (void)errorCalendarFbEventsRequest:(NSDictionary *)userInfo;

@end



@implementation ATCalendarTableViewController

@synthesize dataArray = _dataArray;
@synthesize dataDictionary = _dataDictionary;
@synthesize eventArray = _eventArray;
@synthesize startDate = _startDate;
@synthesize lastDate = _lastDate;
@synthesize titleView = _titleView;
@synthesize shadowView = _shadowView;
@synthesize keyword = _keyword;
@synthesize keyword_or = _keyword_or;

#define countMarks 42
#define countParam 50

static NSString *atndEventSearchUrl = @"http://api.atnd.org/events/";

- (id)init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (self) {
        [self initATCalendarTableViewController];
    }
    return self;
}

- (void)initATCalendarTableViewController {
    LOG_CURRENT_METHOD;
    POOL_START;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationDidFinishLaunching:) 
                                                 name:UIApplicationDidFinishLaunchingNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationWillEnterForeground:) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationDidBecomeActive:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationCalendarEventsRequest:) 
                                                 name:ATNotificationNameCalendarEventsRequest 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationFbEventsRequest:) 
                                                 name:ATNotificationNameFbEventsRequest 
                                               object:nil];
    
    self.dataArray = [NSMutableArray array];
    for (NSUInteger i=0; i<countMarks; i++) {
        [_dataArray addObject:[NSNumber numberWithBool:NO]];
    }
    self.dataDictionary = [NSMutableDictionary dictionary];
    self.eventArray = [NSMutableArray arrayWithCapacity:0];
    
    [self setupLoadTerm:[NSDate dateFromYmdString:[[NSDate date] stringYmd]]];
    
    _customRightBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 44.01f)];
    _reloadButtonItem = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                         target:self
                         action:@selector(reloadAction:) 
                         ];
    _reloadButtonItem.style = UIBarButtonItemStyleBordered;
    
    _stopButtonItem = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                       target:self
                       action:@selector(stopAction:) 
                       ];
    _stopButtonItem.style = UIBarButtonItemStyleBordered;
    
    UIButton *zoominButton = [UIButton buttonWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 44.0f) 
                                                 image:[[ATResource sharedATResource] imageOfPath:@"atndcal.bundle/images/parts/curloff3430.png"]];
    zoominButton.imageEdgeInsets = UIEdgeInsetsMake(7.0f, 3.0f, 7.0f, 3.0f);
    [zoominButton addTarget:self action:@selector(zoominAction:) forControlEvents:UIControlEventTouchUpInside];
    _zoominButtonItem = [[UIBarButtonItem alloc] initWithCustomView:zoominButton];
    
    UIButton *zoomoutButton = [UIButton buttonWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 44.0f) 
                                                  image:[[ATResource sharedATResource] imageOfPath:@"atndcal.bundle/images/parts/curlon3430.png"]];
    zoomoutButton.imageEdgeInsets = UIEdgeInsetsMake(7.0f, 3.0f, 7.0f, 3.0f);
    [zoomoutButton addTarget:self action:@selector(zoomoutAction:) forControlEvents:UIControlEventTouchUpInside];
    _zoomoutButtonItem = [[UIBarButtonItem alloc] initWithCustomView:zoomoutButton];
    
    _shadowView = [[UIImageView alloc] initWithImage:[[ATResource sharedATResource] imageOfPath:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png"]];
    CGRect r = _shadowView.bounds;
    r.origin.y -= 44*4;
    _shadowView.frame = r;
    _shadowView.alpha = 0.0f;
    
    POOL_END;
}


- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameCalendarEventsRequest];

    [_dataArray release];
    [_dataDictionary release];
    [_eventArray release];
    [_startDate release];
    [_lastDate release];
    [_titleView release];
    [_shadowView release];
    [_keyword release];
    [_keyword_or release];
    
    [_customRightBar release];
    [_reloadButtonItem release];
    [_stopButtonItem release];
    [_zoominButtonItem release];
    [_zoomoutButtonItem release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView {
    LOG_CURRENT_METHOD;
    POOL_START;

    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: _shadowView];
    
    UIToolbar *tb = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.01f)] autorelease];
    UIBarButtonItem *otherButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                      target:self 
                                                                                      action:@selector(otherAction:)] autorelease];
    otherButtonItem.style = UIBarButtonItemStyleBordered;

    [tb setItems:[NSArray arrayWithObject:otherButtonItem]];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:tb] autorelease];   
    self.titleView = [[[ATCalendarTitleView alloc] init] autorelease];
    _titleView.delegate = self;
    self.navigationItem.titleView = _titleView;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_customRightBar] autorelease];
    [self refleshRightBarButton];
    
    POOL_END;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    
    POOL_START;

    self.dataDictionary = [ATEventOutlineManager fetchDictionaryForCalendar];

    
    [self refleshCalenderWithSelectDate:_startDate];
    
    _titleView.searchBar.text = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsFinalCalendarSearchText];

    if (_isAutoLoading) {
        _isAutoLoading = NO;
        [self reloadAction:nil];
    }
    POOL_END;
}

- (void)viewDidUnload {
    LOG_CURRENT_METHOD;
    [super viewDidUnload];
    _isZoom = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    LOG_CURRENT_METHOD;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TKCalendarMonthView Delegate & DataSource

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
    LOG_CURRENT_METHOD;
    NSDate *date = startDate;
    for (NSInteger i=0; i<countMarks; i++) {
        NSArray *array = [_dataDictionary objectForKey:date];
        if (array && array.count > 0) {
            [self.dataArray replaceObjectAtIndex:i 
                                      withObject:[NSNumber numberWithBool:YES]];
        } else {
            [self.dataArray replaceObjectAtIndex:i 
                                      withObject:[NSNumber numberWithBool:NO]];
        }
        date = [date dateByAddingDays:1];
    }
    
	return _dataArray;
}

- (void)calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date {
    LOG_CURRENT_METHOD;
    [_titleView setDate:date];
	[self.tableView reloadData];
}

- (void)calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)d animated:(BOOL)animated {
    LOG_CURRENT_METHOD;
	[super calendarMonthView:mv monthDidChange:d animated:animated];
	[self.tableView reloadData];
}

#pragma mark - UITableView Delegate & DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
    NSInteger count = 0;
	NSArray *array = [_dataDictionary objectForKey:[self.monthView dateSelected]];
    if (array) {
        count = array.count;
    }
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *IdATEventOutlineCell = @"ATEventOutlineCell";
    
    ATEventOutlineCell *cell = (ATEventOutlineCell *)[tv dequeueReusableCellWithIdentifier:IdATEventOutlineCell];
    if (!cell) {
        cell = [[[ATEventOutlineCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                          reuseIdentifier:IdATEventOutlineCell] autorelease];
    }
    NSArray *array = [_dataDictionary objectForKey:[self.monthView dateSelected]];
    ATEventOutline *outline = [array objectAtIndex:indexPath.row];
    cell.eventOutline = outline;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ATEventOutlineCell heightCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *array = [_dataDictionary objectForKey:[self.monthView dateSelected]];
    ATEventOutline *outline = [array objectAtIndex:indexPath.row];
    if (outline.type == ATEventTypeAtnd) {
        ATAtndEventDetailViewController *ctl = [[[ATAtndEventDetailViewController alloc] 
                                                 initWithEventObject:outline.eventObject] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (outline.type == ATEventTypeFacebook) {
        ATFbEventDetailViewController *ctl = [[[ATFbEventDetailViewController alloc] 
                                               initWithEventObject:outline.eventObject] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    POOL_END;
}

#pragma mark - ATCalendarTitleViewDelegate


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    [self setupKeyword:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    [self reloadAction:nil];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATWordSelectViewCotroller *ctl = [[[ATWordSelectViewCotroller alloc] init] autorelease];
    ctl.delegate = self;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
    [self presentModalViewController:nav animated:YES];
    
    POOL_END;
}

#pragma mark - ATWordSelectDelegate

- (void)wordSelect:(NSString *)text {
    LOG_CURRENT_METHOD;
    _titleView.searchBar.text = text;
    [self setupKeyword:text];
}


#pragma mark - Public

- (void)zoominAction:(id)sender {
    LOG_CURRENT_METHOD;
    _isZoom = YES;
    [self zoomAnimation];
    [self refleshRightBarButton];
}

- (void)zoomoutAction:(id)sender {
    LOG_CURRENT_METHOD;
    _isZoom = NO;
    [self zoomAnimation];
    [self refleshRightBarButton];
}

- (void)reloadAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;

    NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] 
                                            initWithTarget:self 
                                            selector:@selector(clearSavedEventData) 
                                            object:nil] autorelease];
    invOperation.queuePriority = NSOperationQueuePriorityVeryLow;
    [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
    
    [self resetData];

    [_titleView.searchBar resignFirstResponder];

    NSString *searchText = _titleView.searchBar.text;
    [self setupKeyword:searchText];

    if (searchText && searchText.length > 0) {
        ATKeywordHistoryManager *manager = [ATKeywordHistoryManager sharedATKeywordHistoryManager];
        [manager saveKeyword:searchText];
    }

    NSDate *selectedDate = [self.monthView dateSelected];
    if (selectedDate) {
        [self setupLoadTerm:selectedDate];
    }
    
    [self reloadAtnd:nil];
    
    [self reloadFacebook:nil];

#if DEBUG
    NSString *message = [NSString stringWithFormat:@"読込中 : \nkeyword=%@\nkeyword_or=%@\nstartDate=%@\nlastDate=%@", 
                         _keyword, _keyword_or, _startDate, _lastDate];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
#endif
    
    POOL_END;
}

- (void)stopAction:(id)sender {
    LOG_CURRENT_METHOD;

    _countLoading = 0;
    [self refleshRightBarButton];
    
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameCalendarEventsRequest];
}

- (void)otherAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;

    ATMenuViewController *ctl = [[[ATMenuViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
    [self presentModalViewController:nav animated:YES];
    
    POOL_END;
}


- (void)resetData {
    LOG_CURRENT_METHOD;
    for (NSUInteger i=0; i<countMarks; i++) {
        [_dataArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
    [_dataDictionary removeAllObjects];
    [_eventArray removeAllObjects];
    
    
    [self refleshCalenderWithSelectDate:nil];
    [self.tableView reloadData];
}


#pragma mark - Private

- (void)clearSavedEventData {
    [[ATEventForDateManager sharedATEventForDateManager] truncate];
}

- (void)setupLoadTerm:(NSDate *)startDate {
    self.startDate = startDate;
    NSNumber *loadDays = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsSettingAtndLoadDaysValue];
    self.lastDate = [startDate dateByAddingDays:[loadDays integerValue]];
}

- (void)refleshRightBarButton {
    LOG_CURRENT_METHOD;
    POOL_START;
    [_customRightBar setItems:[self arrayForCustomRightBarButton]];
    POOL_END;
}

- (NSArray *)arrayForCustomRightBarButton {
    LOG_CURRENT_METHOD;
    id firstButton = (_countLoading ? _stopButtonItem : _reloadButtonItem);
    id secondButton = (_isZoom ? _zoomoutButtonItem : _zoominButtonItem);
    
    return [NSArray arrayWithObjects:firstButton, secondButton, nil];
}

- (void)zoomAnimation {
    LOG_CURRENT_METHOD;
    CGFloat adjustHeight = self.monthView.frame.size.height * (_isZoom?(1):(-1));
    CGRect tvRect = self.tableView.frame;
    CGFloat adjustWidth = 50.0f * (_isZoom?(1):(-1));
    CGRect sbRect = _titleView.searchBar.frame;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4f];
    
    [UIView setAnimationTransition:(_isZoom?UIViewAnimationTransitionCurlUp:UIViewAnimationTransitionCurlDown)
                            forView:self.monthView
                              cache:YES];
    self.monthView.alpha = !_isZoom;
    self.shadowView.alpha = _isZoom;

    _titleView.searchBar.frame = CGRectMake(sbRect.origin.x, 
                                            sbRect.origin.y, 
                                            sbRect.size.width-adjustWidth, 
                                            sbRect.size.height);
    
    self.tableView.frame = CGRectMake(tvRect.origin.x, 
                                      tvRect.origin.y-adjustHeight, 
                                      tvRect.size.width, 
                                      tvRect.size.height+adjustHeight);
    
	[UIView commitAnimations];
}


- (void)reloadAtnd:(id)sender {
    POOL_START;
    NSString *ymd = [_startDate stringYmd];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:ymd forKey:@"ymd"];
    if (_keyword) {
        [param setObject:[_keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
    }
    if (_keyword_or) {
        [param setObject:[_keyword_or stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"keyword_or"];
    }
    [self requestAtnd:param];
    POOL_END;
}

- (void)reloadFacebook:(id)sender {
    POOL_START;
    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    
    if (fbConnecter.authStatus == ATFacebookAuthStatusProcessing) {
        [fbConnecter addObserver:self 
                      forKeyPath:@"authStatus" 
                         options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                         context:NULL];
    } else if (fbConnecter.authStatus == ATFacebookAuthStatusSuccessed) {
        [self requestFacebook:nil];
    }
    POOL_END;
}

- (void)requestAtnd:(NSDictionary *)param {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    _countLoading++;
    [self refleshRightBarButton];    
    
    NSString *start = [param objectForKey:@"start"];
    if (!start) {
        self.eventArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    NSMutableDictionary *requestParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [requestParam setObject:@"json" forKey:@"format"];
    [requestParam setObject:[NSString stringWithFormat:@"%d", countParam] forKey:@"count"];
    
    LOG(@"requestParam=%@", [requestParam description]);
    
    NSString *paramString = [NSString stringForURLParam:requestParam method:@"GET"];
    NSString *url = [NSString stringWithFormat:@"%@%@", atndEventSearchUrl, paramString];
    
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:requestParam forKey:@"param"];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameCalendarEventsRequest
                                                                          request:request
                                                                         userInfo:userInfo] 
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];

    POOL_END;
}

- (void)requestFacebook:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    _countLoading++;
    [self refleshRightBarButton];    
    
    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    NSURLRequest *request = [fbConnecter requestEventListForMe];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameFbEventsRequest
                                                                          request:request] 
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
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

- (void)nextDayRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSMutableDictionary *param = [userInfo objectForKey:@"param"];
    
    NSString *ymd = [param objectForKey:@"ymd"];
    NSDate *date = [NSDate dateFromYmdString:ymd];
    date = [date dateByAddingDays:1];
    NSString *nextYmd = [date stringYmd];
    
    [param setObject:nextYmd forKey:@"ymd"];
    [param removeObjectForKey:@"start"];
    
    [self requestAtnd:param];
    
    POOL_END;
}


- (void)refleshCalenderOfDate:(NSDate *)date eventArray:(NSArray *)eventArray type:(ATEventType)type {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSMutableArray *arrayOutline = [NSMutableArray arrayWithCapacity:0];
    for (id object in eventArray) {
        ATEventOutline *eventOutline = [[ATEventOutline alloc] init];
        [eventOutline setEventObject:object type:type];
        [arrayOutline addObject:eventOutline];
        [eventOutline release];
    }
    
    NSMutableArray *array = [_dataDictionary objectForKey:date];
    if (!array) {
        array = [NSMutableArray arrayWithCapacity:0];
        [_dataDictionary setObject:array forKey:date];
    }
    [array addObjectsFromArray:arrayOutline];
    [self performSelectorOnMainThread:@selector(refleshCalenderWithSelectDate:) withObject:date waitUntilDone:NO];
    POOL_END;
}

- (void)refleshCalenderWithSelectDate:(NSDate *)date {
    LOG_CURRENT_METHOD;
    NSDate *selectedDate = [self.monthView dateSelected];
    [self.monthView reload];
    if (selectedDate) {
        [self.monthView selectDate:selectedDate];
    } else if (date) {
        [self.monthView selectDate:date];
        [_titleView setDate:date];
    }
    [self.tableView reloadData];
}

- (void)setupKeyword:(NSString *)text {
    LOG_CURRENT_METHOD;
    
    POOL_START;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:text forKey:kDefaultsFinalCalendarSearchText];
    [defaults synchronize];

    if (text && text.length > 0) {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *sepalatedArray = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", 　"]];
        
        BOOL isOR = NO;
        NSMutableArray *words = [NSMutableArray arrayWithCapacity:0];
        for (NSString *s in sepalatedArray) {
            if (s.length > 0) {
                if ([[s uppercaseString] isEqualToString:@"OR"]) {
                    isOR = YES;
                } else {
                    [words addObject:s];
                }
            }
        }
        NSString *joinedWords = [words componentsJoinedByString:@","];
        
        if (isOR) {
            self.keyword = nil;
            self.keyword_or = joinedWords;
        } else {
            self.keyword = joinedWords;
            self.keyword_or = nil;
        }
    } else {
        self.keyword = nil;
        self.keyword_or = nil;
    }
    
    POOL_END;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    if ([keyPath isEqualToString:@"authStatus"]) {
        
        [[ATCommon facebookConnecter] removeObserver:self forKeyPath:@"authStatus"];
        if ([[change objectForKey:@"new"] integerValue] == ATFacebookAuthStatusSuccessed) {
            [self requestFacebook:nil];
        }
    }
}

#pragma mark - AtndRequest Callback

- (void)notificationCalendarEventsRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    _countLoading--;

    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] initWithTarget:self 
                                                                                    selector:@selector(successCalendarEventsRequest:) 
                                                                                      object:userInfo] autorelease];
        invOperation.queuePriority = NSOperationQueuePriorityHigh;
        [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
       
    } else {
        [self errorCalendarEventsRequest:userInfo];
    }
}

- (void)successCalendarEventsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    
    POOL_START;
    
    NSDictionary *param = [userInfo objectForKey:@"param"];
    
    NSString *ymd = [param objectForKey:@"ymd"];
    NSDate *date = [NSDate dateFromYmdString:ymd];

    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *dictionary = [ATEventManager dictionaryWithJson:jsonString];
    
    NSString *results_returned = [dictionary objectForKey:@"results_returned"];
    NSInteger iResultsReturned = [results_returned integerValue];
    
    NSArray *array = nil;
    double intervalCondition = [[NSUserDefaults standardUserDefaults] doubleForKey:kDefaultsSettingAtndIntervalConditionValue];
    if (intervalCondition > 0) {
        NSMutableArray *eventsArray = [NSMutableArray arrayWithCapacity:0];
        for (id e in [dictionary objectForKey:@"events"]) {
            ATEvent *event = [ATEventManager eventWithEventObject:e];
            NSDate *startDate = [NSDate dateForAtndDateString:event.started_at];
            NSDate *endDate = [NSDate dateForAtndDateString:event.ended_at];
            NSTimeInterval sInterval = [startDate timeIntervalSince1970];
            NSTimeInterval eInterval = [endDate timeIntervalSince1970];
            if (!endDate || eInterval-sInterval < intervalCondition) {
                [eventsArray addObject:e];
            }
        }
        array = eventsArray;
    } else {
        array = [dictionary objectForKey:@"events"];
    }
    [_eventArray addObjectsFromArray:array];
    
    NSInteger iCount = [[param objectForKey:@"count"] integerValue];
    if (iCount > iResultsReturned) {
        
        [self refleshCalenderOfDate:date eventArray:_eventArray type:ATEventTypeAtnd];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    date, @"date",
                                    [NSArray arrayWithArray:_eventArray], @"eventArray", nil];

        NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] initWithTarget:self 
                                                                                    selector:@selector(saveEventArray:)  
                                                                                      object:dictionary] autorelease];
        invOperation.queuePriority = NSOperationQueuePriorityVeryLow;
        [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
        
        NSComparisonResult result = [date compare:_lastDate];
        if (result == NSOrderedAscending) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:param forKey:@"param"];
            [self performSelectorOnMainThread:@selector(nextDayRequest:) withObject:userInfo waitUntilDone:YES];
        } else {
            //end
            [self performSelectorOnMainThread:@selector(refleshRightBarButton) withObject:nil waitUntilDone:NO];
        }

    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:param forKey:@"param"];
        [self performSelectorOnMainThread:@selector(nextStartRequest:) withObject:userInfo waitUntilDone:YES];
    }
    
    POOL_END;
}

- (void)errorCalendarEventsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    [self refleshRightBarButton];

    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSString *message = [NSString stringWithFormat:@"ATND Server Error\nStatus : %@ \n %@",  
                         [userInfo objectForKey:kATRequestUserInfoStatusCode],
                         [error localizedDescription]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameCalendarEventsRequest];
    POOL_END;
}


- (void)saveEventArray:(NSDictionary *)dictionary {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSDate *date = [dictionary objectForKey:@"date"];
    NSArray *eventArray = [dictionary objectForKey:@"eventArray"];
    
    ATEventForDateManager *manager = [ATEventForDateManager sharedATEventForDateManager];
    [manager arrayEventForDateWithEventArray:eventArray 
                                        type:ATEventTypeAtnd 
                                        date:date];
    
    NSError *error = [manager save];
    if (error) {
        LOG(@"save error:%@", [error localizedDescription]);
    }
    POOL_END;
}


#pragma mark - FacebookRequest Callback

- (void)notificationFbEventsRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;

    _countLoading--;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    LOG(@"error=%@", [error localizedDescription]);
    LOG(@"statusCode=%d", [statusCode intValue]);
    if (!error && statusCode && [statusCode integerValue] == 200) {
        NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] initWithTarget:self 
                                                                                    selector:@selector(successCalendarFbEventsRequest:) 
                                                                                      object:userInfo] autorelease];
        invOperation.queuePriority = NSOperationQueuePriorityHigh;
        [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
    } else {
        [self errorCalendarFbEventsRequest:userInfo];
    }
}

- (void)successCalendarFbEventsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSData *data = [userInfo objectForKey:kATRequestUserInfoReceivedData];
    NSString *jsonString = [[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding] autorelease];
    NSArray *array = [ATFbEventManager arrayWithJson:jsonString];
    
    for (id object in array) {
        ATFbEvent *fbEvent = [ATFbEventManager fbEventWithFbEventObject:object];
        NSDate *date = [ATFbEventManager dateYmdStartTimeFromFbEvent:fbEvent];
        [self refleshCalenderOfDate:date eventArray:[NSArray arrayWithObject:object] type:ATEventTypeFacebook];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    if (array) {
        [dictionary setObject:array forKey:@"eventArray"];
    }
    
    NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] initWithTarget:self 
                                                                                selector:@selector(saveFbEventArray:)  
                                                                                  object:dictionary] autorelease];
    invOperation.queuePriority = NSOperationQueuePriorityVeryLow;
    [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
    
    [self performSelectorOnMainThread:@selector(refleshRightBarButton) withObject:nil waitUntilDone:NO];
    POOL_END;
}

- (void)errorCalendarFbEventsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [self refleshRightBarButton];
    
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSString *message = [NSString stringWithFormat:@"Facebook ServerError\nStatus : %@ \n %@",  
                         [userInfo objectForKey:kATRequestUserInfoStatusCode],
                         [error localizedDescription]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];

    POOL_END;
}

- (void)saveFbEventArray:(NSDictionary *)dictionary {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSArray *eventArray = [dictionary objectForKey:@"eventArray"];
    
    ATEventForDateManager *manager = [ATEventForDateManager sharedATEventForDateManager];
    for (id object in eventArray) {
        POOL_START;
        ATFbEvent *fbEvent = [ATFbEventManager fbEventWithFbEventObject:object];
        NSDate *date = [ATFbEventManager dateYmdStartTimeFromFbEvent:fbEvent];
        [manager arrayEventForDateWithEventArray:[NSArray arrayWithObject:object] 
                                            type:ATEventTypeFacebook 
                                            date:date];
        POOL_END;
    }
    
    NSError *error = [manager save];
    if (error) {
        LOG(@"save error:%@", [error localizedDescription]);
    }
    POOL_END;
}



#pragma mark - NotificationObserver:

- (void)notificationDidFinishLaunching:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    NSNumber *autoLoading = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsSettingAutoLoadingValue];
    _isAutoLoading = [autoLoading boolValue];
}

- (void)notificationWillEnterForeground:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSNumber *autoLoading = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsSettingAutoLoadingValue];
    if ([autoLoading boolValue]) {
        [self.monthView selectDate:[NSDate dateFromYmdString:[[NSDate date] stringYmd]]];
        [self reloadAction:nil];
    }
    POOL_END;
}

- (void)notificationDidBecomeActive:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
}


@end
