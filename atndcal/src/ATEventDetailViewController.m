//
//  ATEventDetailViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventDetailViewController.h"
#import <Twitter/Twitter.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ATCommon.h"

#import "ATWebViewController.h"
#import "ATEkEventViewController.h"
#import "ATEventForBookmark.h"

#import "ATLdWeatherConnecter.h"
#import "ATLwwsXmlParser.h"
#import "ATLwwsCell.h"

@interface ATEventDetailViewController ()
@property (nonatomic, retain) id eventObject;
@property (nonatomic, retain) ATTitleView *titleView;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) ATMailComposer *mailComposer;

- (void)initATEventDetailViewController;
- (NSString *)titleString;
- (NSArray *)fetchEventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (NSString *)stringForLwwsDayParamWithToday:(NSDate *)todayDate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (ATRssLdWeather *)searchRssLdWeather:(NSString *)string;
- (void)requestLwwsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (void)scheduleAlarmForDate:(NSDate *)theDate message:(NSString *)message;

- (void)successLwwsRequest:(NSDictionary *)userInfo;
- (void)errorLwwsRequest:(NSDictionary *)userInfo;
@end

@implementation ATEventDetailViewController
@synthesize eventObject = _eventObject;
@synthesize titleView = _titleView;
@synthesize bookmarkedIdentifier = _bookmarkedIdentifier;
@synthesize eventStore = _eventStore;
@synthesize defaultCalendar = _defaultCalendar;
@synthesize mailComposer = _mailComposer;
@synthesize lwws = _lwws;
@synthesize rssLdWeather = _rssLdWeather;

static NSString *starString = nil;
static NSString * const newImage = NewImageCenterImage;

static NSString *lwwsUrl = @"http://weather.livedoor.com/forecast/webservice/rest/v1";

- (id)initWithEventObject:(id)eventObject {
    LOG_CURRENT_METHOD;
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.eventObject = eventObject;
        [self initATEventDetailViewController];
    }
    return self;
}

- (void)initATEventDetailViewController {
    if (!starString) {
        unsigned char bytes[2] = {0xe3,0x2f};
        starString = [[NSString alloc] initWithBytes:bytes length:2 encoding:NSUTF16StringEncoding];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationLwwsRequest:) 
                                                 name:ATNotificationNameLwwsRequest 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(newImageRetrieved) 
                                                 name:newImage 
                                               object:nil];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ATNotificationNameLwwsRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:newImage object:nil];

    [_eventObject release];
    [_bookmarkedIdentifier release];
    [_titleView release];
    [_eventStore release];
    [_defaultCalendar release];
    [_mailComposer release];
    [_lwws release];
    [_rssLdWeather release];
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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                            target:self 
                                                                                            action:@selector(otherAction:)] autorelease];
    
    
    
    self.titleView = [[[ATTitleView alloc] init] autorelease];
    [_titleView setTitle:[self titleString]];
    self.navigationItem.titleView = _titleView;
    POOL_END;
}


- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    POOL_START;
    [super viewDidLoad];
    
    self.eventStore = [[[EKEventStore alloc] init] autorelease];
	self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
    POOL_END;
}

- (void)viewDidUnload {
    LOG_CURRENT_METHOD;
    POOL_START;
    [super viewDidUnload];
    POOL_END;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private

- (NSString *)titleString {
    static NSString *titleFormat = @"%@%@";
    NSString *titleString = nil;
    if (_bookmarkedIdentifier) {
        titleString = [NSString stringWithFormat:titleFormat, starString, [self eventTitle]];
    } else {
        titleString = [self eventTitle];
    }
    return titleString;
}

- (NSArray *)fetchEventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
	LOG_CURRENT_METHOD;
    
    if (!endDate) {
        endDate = startDate;
    }
    
    NSDate *startYmdDate = [NSDate dateFromYmdString:[startDate stringYmd] timeZone:[NSTimeZone localTimeZone]];
    NSDate *endYmdDate = [NSDate dateFromYmdString:[endDate stringYmd] timeZone:[NSTimeZone localTimeZone]];
    endYmdDate = [endYmdDate dateByAddingDays:1];
    
	NSArray *calendarArray = [NSArray arrayWithObject:_defaultCalendar];
    
	NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startYmdDate 
                                                                      endDate:endYmdDate 
                                                                    calendars:calendarArray]; 
	NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
	return events;
}

- (NSString *)stringForLwwsDayParamWithToday:(NSDate *)todayDate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    static NSString *today = @"today";
    static NSString *tomorrow = @"tomorrow";
    static NSString *dayaftertomorrow = @"dayaftertomorrow";
    
    NSString *day = nil;
    NSDate *tomorrowDate = [todayDate dateByAddingDays:1];
    NSDate *dayAfterTomorrowDate = [tomorrowDate dateByAddingDays:1];

    if ([todayDate isSameDay:startDate]) {
        day = today;
    } else if ([tomorrowDate isSameDay:startDate]) {
        day = tomorrow;
    } else if ([dayAfterTomorrowDate isSameDay:startDate]) {
        day = dayaftertomorrow;
    } else {
        if ([todayDate compare:startDate] > 0) {
            if ([todayDate compare:endDate] < 0) {
                day = today;
            }
        } else {
            day = dayaftertomorrow;
        }
    }
    return day;
}

- (ATRssLdWeather *)searchRssLdWeather:(NSString *)string {
    ATRssLdWeather *rssLdWeather = nil;
    NSArray *forecasts = [[ATLdWeatherConnecter sharedATLdWeatherConnecter] forecasts];
    for (ATRssLdWeather *rss in forecasts) {
        NSRange r = [string rangeOfString:rss.title];
        if (r.location != NSNotFound) {
            rssLdWeather = rss;
            break;
        }
    }
    return rssLdWeather;
}

- (void)requestLwwsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSString *day = [self stringForLwwsDayParamWithToday:[NSDate date] startDate:startDate endDate:endDate];
    if (day && _rssLdWeather) {
        NSMutableDictionary *requestParam = [NSMutableDictionary dictionary];
        [requestParam setObject:_rssLdWeather.id_ forKey:@"city"];
        [requestParam setObject:day forKey:@"day"];
        LOG(@"requestParam=%@", [requestParam description]);
        
        NSString *paramString = [NSString stringForURLParam:requestParam method:@"GET"];
        NSString *url = [NSString stringWithFormat:@"%@%@", lwwsUrl, paramString];
        
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:30.0f] autorelease];
        ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                     notificationName:ATNotificationNameLwwsRequest
                                                                              request:request] 
                                         autorelease];
        [operation setQueuePriority:NSOperationQueuePriorityHigh];
        [[ATOperationManager sharedATOperationManager] addOperation:operation];
    }
}

- (void)scheduleAlarmForDate:(NSDate *)theDate message:(NSString *)message {
    POOL_START;

    UILocalNotification *alarm = [[[UILocalNotification alloc] init] autorelease];
    if (alarm) {
        alarm.fireDate = theDate;
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.soundName = UILocalNotificationDefaultSoundName;
        alarm.alertBody = message;
        [[UIApplication sharedApplication] scheduleLocalNotification:alarm];
    }
    POOL_END;
}


#pragma mark - Public

- (NSString *)eventTitle {
    return nil;
}

- (void)setBookmarkedIdentifierWithEventId:(NSString *)eventId type:(ATEventType)type {
    ATEventForBookmark *bookmark = [[ATEventForBookmarkManager sharedATEventForBookmarkManager] fetchEventForBookmarkFromEventId:eventId type:type];
    if (_bookmarkedIdentifier != bookmark.identifier) {
        [_bookmarkedIdentifier release];
        _bookmarkedIdentifier = [bookmark.identifier copy];
    }
}

- (void)openWebView:(id)sender url:(NSString *)urlString {
    LOG_CURRENT_METHOD;
    POOL_START;
    ATWebViewController *ctl = [[[ATWebViewController alloc] initWithUrlString:urlString] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
    [self presentModalViewController:nav animated:YES];
    POOL_END;
}

- (void)openSafari:(id)sender url:(NSString *)urlString {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    POOL_END;
}

- (void)openMap:(id)sender keyword:(NSString *)keyword {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSString *urlString = [NSString stringMapsUrlWithKeyword:keyword];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    POOL_END;
}

- (void)searchByGoogle:(id)sender keyword:(NSString *)keyword {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSString *urlString = [NSString stringSearchGoogleUrlWithKeyword:keyword];
    [self openWebView:sender url:urlString];
    POOL_END;
}

- (void)addEkEvent:(id)sender 
             title:(NSString *)title 
          location:(NSString *)location 
         startDate:(NSDate *)startDate 
           endDate:(NSDate *)endDate {
    LOG_CURRENT_METHOD;
    POOL_START;

    EKEvent *ekEvent = [EKEvent eventWithEventStore:_eventStore];
    ekEvent.title = title;
    ekEvent.location = location;
    ekEvent.startDate = startDate;
    ekEvent.endDate = endDate;

	EKEventEditViewController *addController = [[[EKEventEditViewController alloc] init] autorelease];
	addController.editViewDelegate = self;
    addController.event = ekEvent;
	addController.eventStore = _eventStore;
	
	[self presentModalViewController:addController animated:YES];
    
    POOL_END;
}

- (void)showEkEvent:(id)sender 
          startDate:(NSDate *)startDate 
            endDate:(NSDate *)endDate 
              title:(NSString *)title {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSArray *ekEvents = [self fetchEventsForStartDate:startDate endDate:endDate];
    
    if (ekEvents && ekEvents.count > 0) {
        ATEkEventViewController *ctl = [[[ATEkEventViewController alloc] init] autorelease];
        ctl.titleViewString = title;
        ctl.ekEvents = [NSMutableArray arrayWithArray:ekEvents];
        ctl.eventStore = _eventStore;
        ctl.defaultCalendar = _defaultCalendar;
        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
        [self presentModalViewController:nav animated:YES];
    } else {
        static NSString *message = @"予定はありません.";
        [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    }
    POOL_END;
}


- (void)addBookmark:(id)sender type:(ATEventType)type eventId:(NSString *)eventId {
    LOG_CURRENT_METHOD;
    POOL_START;
    [[ATEventForBookmarkManager sharedATEventForBookmarkManager] saveWithEventObject:_eventObject 
                                                                                type:type];
    [self setBookmarkedIdentifierWithEventId:eventId type:type];
    [_titleView setTitle:[self titleString]];
    [self.tableView reloadData];
    POOL_END;
}

- (void)removeBookmark:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    [[ATEventForBookmarkManager sharedATEventForBookmarkManager] removeObjectAtIdentifier:_bookmarkedIdentifier];
    [_bookmarkedIdentifier release]; _bookmarkedIdentifier = nil;
    [_titleView setTitle:[self titleString]];
    [self.tableView reloadData];
    POOL_END;
}

- (void)sendTweet:(id)sender initialText:(NSString *)initialText url:(NSURL *)url {
    LOG_CURRENT_METHOD;
    POOL_START;
    static NSString *message = @"ツイートしました.";
    
    TWTweetComposeViewController *tweetViewController = [[[TWTweetComposeViewController alloc] init] autorelease];
    [tweetViewController setInitialText:initialText];
    [tweetViewController addURL:url];
    
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        if (result == TWTweetComposeViewControllerResultDone) {
            [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) 
                                                            withObject:message 
                                                         waitUntilDone:NO];
        }
        [self dismissModalViewControllerAnimated:YES];
    }];
    [self presentModalViewController:tweetViewController animated:YES];
    POOL_END;
}

- (void)openMailWithSubject:(NSString *)subject body:(NSString *)body {
    POOL_START;
    
    self.mailComposer = [[[ATMailComposer alloc] init] autorelease];
    [_mailComposer setSubject:subject];
    [_mailComposer setBody:body];
    [_mailComposer setIsHTML:YES];
    [_mailComposer openMailOnViewController:self];
    
    POOL_END;
}

- (void)requestLwws:(NSString *)address location:(CLLocation *)location startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    POOL_START;
    
    static NSString *defaultRssTitle = @"東京";
    
    NSArray *forecasts = [[ATLdWeatherConnecter sharedATLdWeatherConnecter] forecasts];
    self.rssLdWeather = [self searchRssLdWeather:address];
    if (!_rssLdWeather) {
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error){
                for (CLPlacemark *placemark in placemarks) {
                    NSString *addressString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                    self.rssLdWeather = [self searchRssLdWeather:addressString];
                    [addressString release];
                }
            }
            if (!_rssLdWeather) {
                for (ATRssLdWeather *rss in forecasts) {
                    if ([rss.title isEqualToString:defaultRssTitle]) {
                        self.rssLdWeather = rss;
                    }
                }
            }
            [self requestLwwsWithStartDate:startDate endDate:endDate];
        }];
    } else {
        [self requestLwwsWithStartDate:startDate endDate:endDate];
    }

    POOL_END;
}

- (UIActivityIndicatorView *)indicatorViewForCellImage {
    UIActivityIndicatorView *indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    indicatorView.frame = CGRectMake(0.0f,0.0f,30.0f, 30.0f);
    indicatorView.contentMode = UIViewContentModeCenter;
    indicatorView.userInteractionEnabled = NO;
    indicatorView.tag = ATEventCellViewTagIndicator;
    [indicatorView startAnimating];
    return indicatorView;
}


- (void)settingLwwsCell:(ATLwwsCell *)cell {
    static NSString *labelFormat = @"%@  [%@℃ 〜 %@℃]";
    
    POOL_START;
    if (self.lwws) {
        if (self.lwws.imageUrl) {
            UIImage *i = [[TKImageCenter sharedImageCenter] imageAtURL:self.lwws.imageUrl queueIfNeeded:YES];
            if (!i) {
                cell.iconImageView.image = [[[UIImage alloc] init] autorelease];
                [cell.iconImageView addSubview:[self indicatorViewForCellImage]];
            } else {
                cell.iconImageView.image = i;
                [[cell.iconImageView viewWithTag:ATEventCellViewTagIndicator] removeFromSuperview];
            }
        }
        cell.label.text = [NSString stringWithFormat:labelFormat, self.lwws.telop, self.lwws.maxCelsius, self.lwws.minCelsius];
        cell.field.text = [ATLwwsManager stringForDispDescription:self.lwws];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.iconImageView.image = nil;
        cell.label.text = nil;
        cell.field.text = nil;
    }
    
    POOL_END;
}

- (void)selectTimerForNotification:(id)sender message:(NSString *)message startDate:(NSDate *)startDate {
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"イベント前に通知します."] autorelease];
    [actionSheet addButtonWithTitle:@"５日前" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSDate *fireDate = [NSDate dateWithTimeInterval:-1*(60*60*24*5) sinceDate:startDate];
        [self scheduleAlarmForDate:fireDate message:message];
    }];
    [actionSheet addButtonWithTitle:@"１日前" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSDate *fireDate = [NSDate dateWithTimeInterval:-1*(60*60*24*1) sinceDate:startDate];
        [self scheduleAlarmForDate:fireDate message:message];
    }];
    [actionSheet addButtonWithTitle:@"１２時間前" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSDate *fireDate = [NSDate dateWithTimeInterval:-1*(60*60*12) sinceDate:startDate];
        [self scheduleAlarmForDate:fireDate message:message];
    }];
    [actionSheet addButtonWithTitle:@"３時間前" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSDate *fireDate = [NSDate dateWithTimeInterval:-1*(60*60*3) sinceDate:startDate];
        [self scheduleAlarmForDate:fireDate message:message];
    }];
    [actionSheet addButtonWithTitle:@"１時間前" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSDate *fireDate = [NSDate dateWithTimeInterval:-1*(60*60*1) sinceDate:startDate];
        [self scheduleAlarmForDate:fireDate message:message];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];

    POOL_END;
}

#pragma mark - Observer

- (void)newImageRetrieved {
    LOG_CURRENT_METHOD;
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:ATLwwsCell.class]) {
            ATLwwsCell *c = (ATLwwsCell *)cell;
            
            UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:self.lwws.imageUrl queueIfNeeded:NO];
            if(image){
                [[c.iconImageView viewWithTag:ATEventCellViewTagIndicator] removeFromSuperview];
                c.iconImageView.image = image;
                [c setNeedsLayout];
            }
        }
	}
}

#pragma mark - lwws Callback

- (void)notificationLwwsRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successLwwsRequest:userInfo];
    } else {
        [self errorLwwsRequest:userInfo];
    }
}

- (void)successLwwsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSData *data = [userInfo objectForKey:kATRequestUserInfoReceivedData];
    
    ATLwwsXmlParser *parser = [[[ATLwwsXmlParser alloc] init] autorelease];
    [parser parse:data];
    self.lwws = parser.lwws;
    [self.tableView reloadData];
    
    LOG(@"title=%@", parser.lwws.title);
    LOG(@"link=%@", parser.lwws.link);
    LOG(@"telop=%@", parser.lwws.telop);
    LOG(@"description_=%@", parser.lwws.description_);
    LOG(@"imageUrl=%@", parser.lwws.imageUrl);
    LOG(@"maxCelsius=%@", parser.lwws.maxCelsius);
    LOG(@"minCelsius=%@", parser.lwws.minCelsius);
    POOL_END;
}

- (void)errorLwwsRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSString *message = [NSString stringWithFormat:@"LWWS Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameLwwsRequest];
    POOL_END;
}



#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller 
          didCompleteWithAction:(EKEventEditViewAction)action {
    LOG_CURRENT_METHOD;
    POOL_START;

    NSError *error = nil;
	EKEvent *thisEvent = controller.event;
	
	switch (action) {
		case EKEventEditViewActionCanceled:
            LOG(@"EKEventEditViewActionCanceled !!");
			break;
			
		case EKEventEditViewActionSaved:
            LOG(@"EKEventEditViewActionSaved !!");
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			break;
			
		case EKEventEditViewActionDeleted:
            LOG(@"EKEventEditViewActionDeleted !!");
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			break;
			
		default:
			break;
	}
	[controller dismissModalViewControllerAnimated:YES];
    POOL_END;
}

- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    LOG_CURRENT_METHOD;
    return _defaultCalendar;
}

@end
