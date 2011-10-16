//
//  ATEventDetailViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventDetailViewController.h"
#import <Twitter/Twitter.h>
#import "ATCommon.h"

#import "ATWebViewController.h"
#import "ATEkEventViewController.h"
#import "ATEventForBookmark.h"

@interface ATEventDetailViewController ()
@property (nonatomic, retain) id eventObject;
//@property (nonatomic, retain) EKEventViewController *detailViewController;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) ATMailComposer *mailComposer;

- (void)initATEventDetailViewController;
- (NSString *)titleString;
- (NSArray *)fetchEventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
@end

@implementation ATEventDetailViewController
@synthesize eventObject = _eventObject;
@synthesize bookmarkedIdentifier = _bookmarkedIdentifier;
//@synthesize detailViewController = _detailViewController;
@synthesize eventStore = _eventStore;
@synthesize defaultCalendar = _defaultCalendar;
@synthesize mailComposer = _mailComposer;

static NSString *starString = nil;

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
}

- (void)dealloc {
    LOG_CURRENT_METHOD;

    [_eventObject release];
    [_bookmarkedIdentifier release];
    [_titleView release];
    [_eventStore release];
    [_defaultCalendar release];
    [_mailComposer release];
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                           target:self 
                                                                                           action:@selector(otherAction:)];
    
    
    
    _titleView = [[ATTitleView alloc] init];
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
    NSString *titleString = nil;
    if (_bookmarkedIdentifier) {
        titleString = [NSString stringWithFormat:@"%@%@", starString, [self eventTitle]];
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
        NSString *message = [NSString stringWithFormat:@"予定はありません."];
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
    
    TWTweetComposeViewController *tweetViewController = [[[TWTweetComposeViewController alloc] init] autorelease];
    [tweetViewController setInitialText:initialText];
    [tweetViewController addURL:url];
    
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        if (result == TWTweetComposeViewControllerResultDone) {
            NSString *message = @"ツイートしました.";
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
