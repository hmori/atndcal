//
//  ATFbEventDetailViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATFbEventDetailViewController.h"
#import <Twitter/Twitter.h>

#import "ATCommon.h"
#import "ATFbEventStatusViewController.h"
#import "ATTextAnalysisViewController.h"

#import "ATTitleView.h"

#import "ATEventDateCell.h"
#import "ATEventTextCell.h"
#import "ATEventLabelTextCell.h"
#import "ATEventMapCell.h"

typedef enum {
    ATFbEventDetailItemNone,
    ATFbEventDetailItemStatus,
    ATFbEventDetailItemDate,
    ATFbEventDetailItemOwner,
    ATFbEventDetailItemPlace,
    ATFbEventDetailItemAddress,
    ATFbEventDetailItemVenue,
    ATFbEventDetailItemMap,
    ATFbEventDetailItemDescription,
    ATFbEventDetailItemDescriptionContinue,
    ATFbEventDetailItemGuest,
} ATFbEventDetailItem;


@interface ATFbEventDetailViewController ()
@property (nonatomic, retain) ATFbEvent *event;
@property (nonatomic, retain) ATFbEventStatus *eventStatus;
@property (nonatomic, retain) NSArray *commentItems;
@property (nonatomic, retain) NSMutableArray *itemsInSection0;
@property (nonatomic, retain) NSMutableArray *itemsInSection1;
@property (nonatomic, retain) NSMutableArray *itemsInSection2;
@property (nonatomic, retain) NSMutableArray *itemsInSection3;
@property (nonatomic, retain) NSMutableArray *itemsInSection4;

- (void)initATFbEventDetailViewController;

- (void)setupItems;
- (ATFbEventDetailItem)eventDetailItemAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForIdentifier:(ATEventCellType)type tableView:(UITableView *)tv;
- (void)addEkEventFacebook:(id)sender;
- (void)showEkEventFacebook:(id)sender;
- (void)openMail:(id)sender;

- (void)successFbRsvpStatusRequest:(NSDictionary *)userInfo;
- (void)errorFbRsvpStatusRequest:(NSDictionary *)userInfo;

@end



@implementation ATFbEventDetailViewController

@synthesize event = _event;
@synthesize eventStatus = _eventStatus;
@synthesize commentItems = _commentItems;
@synthesize itemsInSection0 = _itemsInSection0;
@synthesize itemsInSection1 = _itemsInSection1;
@synthesize itemsInSection2 = _itemsInSection2;
@synthesize itemsInSection3 = _itemsInSection3;
@synthesize itemsInSection4 = _itemsInSection4;

static NSString *fbMobileWebEventUrl = @"http://m.facebook.com/event.php?eid=";
static NSString *fbWebEventUrl = @"http://www.facebook.com/event.php?eid=";

- (id)initWithEventObject:(id)eventObject {
    LOG_CURRENT_METHOD;
    self = [super initWithEventObject:eventObject];
    if (self) {
        POOL_START;
        self.event = [ATFbEventManager fbEventWithFbEventObject:eventObject];
        [self initATFbEventDetailViewController];
        POOL_END;
    }
    return self;
}

- (void)initATFbEventDetailViewController {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationFbRsvpStatusRequest:) 
                                                 name:ATNotificationNameFbRsvpStatusRequest 
                                               object:nil];

    [self setBookmarkedIdentifierWithEventId:_event.id_ type:ATEventTypeFacebook];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_event release];
    [_eventStatus release];
    [_commentItems release];
    [_itemsInSection0 release];
    [_itemsInSection1 release];
    [_itemsInSection2 release];
    [_itemsInSection3 release];
    [_itemsInSection4 release];
    [super dealloc];
}

#pragma mark - Setter

- (void)setEvent:(ATFbEvent *)event {
    LOG_CURRENT_METHOD;
    if (_event != event) {
        [_event release];
        _event = [event retain];
        
        [self setupItems];
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    POOL_START;
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [self reloadRsvpStatusAction:nil];
    POOL_END;
}


#pragma mark - Overwride ATEventDetailViewController

- (NSString *)eventTitle {
    return _event.name;
}

#pragma mark - TableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    NSInteger row = 0;
    if (section == 0) {
        row = _itemsInSection0.count;
    } else if (section == 1) {
        row = _itemsInSection1.count;
    } else if (section == 2) {
        row = _itemsInSection2.count;
    } else if (section == 3) {
        row = _itemsInSection3.count;
    } else if (section == 4) {
        row = _itemsInSection4.count;
    }
	return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;

    ATFbEventDetailItem item = [self eventDetailItemAtIndexPath:indexPath];
    if (item == ATFbEventDetailItemNone) {
        height = 0.0f;
    } else if (item == ATFbEventDetailItemMap) {
        height = [ATEventMapCell heightCell];
    } else if (item == ATFbEventDetailItemDescription) {
        height = [ATEventTextCell heightCellOfLabelText:_event.description_ 
                                                   truncate:!_isContinueDescription];
    }

    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        title = _event.name;
    } else if (section == 1) {
        title = @"場所";
    } else if (section == 3) {
        title = @"詳細";
    } else if (section == 4) {
        title = @"出欠の返事";
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    ATFbEventDetailItem item = [self eventDetailItemAtIndexPath:indexPath];
    if (item == ATFbEventDetailItemNone) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    } else if (item == ATFbEventDetailItemDate) {
        NSString *eventDateStart = [ATFbEventManager stringForDispDate:_event fbEventDate:ATFbEventDateStart];
        NSString *eventDateEnd = [ATFbEventManager stringForDispDate:_event fbEventDate:ATFbEventDateEnd];
        
        if (eventDateEnd) {
            cell = [self cellForIdentifier:ATEventCellTypeDate tableView:tv];
            ATEventDateCell *c = (ATEventDateCell *)cell;
            c.label.text = @"日時";
            c.startField.text = [NSString stringWithFormat:@"%@ -", eventDateStart];
            c.endField.text = eventDateEnd;
        } else {
            cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
            ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
            c.label.text = @"日時";
            c.field.text = [NSString stringWithFormat:@"%@ -", eventDateStart];
        }
    } else if (item == ATFbEventDetailItemOwner) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"主催者";
        c.field.text = [NSString stringWithFormat:@"%@", _event.owner];
    } else if (item == ATFbEventDetailItemPlace) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"会場";
        c.field.text = _event.location;
    } else if (item == ATFbEventDetailItemAddress) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"住所";
        c.field.text = [_event.venue objectForKey:@"street"];
    } else if (item == ATFbEventDetailItemMap) {
        cell = [self cellForIdentifier:ATEventCellTypeMap tableView:tv];
        ATEventMapCell *c = (ATEventMapCell *)cell;

        CLLocationCoordinate2D location;
        location.latitude = [[_event.venue objectForKey:@"latitude"] doubleValue];
        location.longitude = [[_event.venue objectForKey:@"longitude"] doubleValue];
        [c setLocation:location];

    } else if (item == ATFbEventDetailItemDescription) {
        cell = [self cellForIdentifier:ATEventCellTypeText tableView:tv];
        ATEventTextCell *c = (ATEventTextCell *)cell;
        c.field.text = _event.description_;
        if (_isContinueDescription) {
            c.field.numberOfLines = INT_MAX;
        } else {
            c.field.numberOfLines = 6;
        }
    } else if (item == ATFbEventDetailItemDescriptionContinue) {
        cell = [self cellForIdentifier:ATEventCellTypeButton tableView:tv];
        TKButtonCell *c = (TKButtonCell *)cell;
        c.textLabel.text = _isContinueDescription?@"閉じる":@"続きを読む";
    } else if (item == ATFbEventDetailItemStatus) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"出欠";
        if (_eventStatus) {
            c.field.text = [ATFbEventStatusManager stringDispStatus:_eventStatus];
        } else {
            c.field.text = nil;
        }
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
 
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    
	[tv deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *controller = nil;
    
    ATFbEventDetailItem item = [self eventDetailItemAtIndexPath:indexPath];
    if (item == ATFbEventDetailItemNone) {
    } else if (item == ATFbEventDetailItemDate) {
        [self dateAction:nil];
    } else if (item == ATFbEventDetailItemOwner) {
        //TODO:
    } else if (item == ATFbEventDetailItemPlace) {
        [self placeAction:nil];
    } else if (item == ATFbEventDetailItemAddress) {
        [self addressAction:nil];
    } else if (item == ATFbEventDetailItemMap) {
        [self mapAction:nil];
    } else if (item == ATFbEventDetailItemDescription) {
        [self textAction:nil text:_event.description_];
    } else if (item == ATFbEventDetailItemDescriptionContinue) {
        _isContinueDescription = !_isContinueDescription;
        [tv reloadData];
    } else if (item == ATFbEventDetailItemStatus) {
        if (_eventStatus) {
            ATFbEventStatusViewController *ctl = [[[ATFbEventStatusViewController alloc] init] autorelease];
            ctl.eventStatus = _eventStatus;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    }
    
    if (controller) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Private

- (void)setupItems {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    self.itemsInSection0 = [NSMutableArray arrayWithCapacity:0];
    self.itemsInSection1 = [NSMutableArray arrayWithCapacity:0];
    self.itemsInSection2 = [NSMutableArray arrayWithCapacity:0];
    self.itemsInSection3 = [NSMutableArray arrayWithCapacity:0];
    self.itemsInSection4 = [NSMutableArray arrayWithCapacity:0];
    
    [_itemsInSection0 addObject:[NSNumber numberWithInt:ATFbEventDetailItemDate]];
    if (_event.owner && (NSNull *)_event.owner != [NSNull null] ) {
        [_itemsInSection0 addObject:[NSNumber numberWithInt:ATFbEventDetailItemOwner]];
    }
    if (_event.location && [_event.location length] > 0) {
        [_itemsInSection1 addObject:[NSNumber numberWithInt:ATFbEventDetailItemPlace]];
    }
    if (_event.venue && [_event.venue isKindOfClass:NSDictionary.class] &&
        [_event.venue objectForKey:@"street"] && [[_event.venue objectForKey:@"street"] length] > 0) {
        
        [_itemsInSection1 addObject:[NSNumber numberWithInt:ATFbEventDetailItemAddress]];
    }
    if (_event.venue && [_event.venue isKindOfClass:NSDictionary.class] &&
        [_event.venue objectForKey:@"latitude"] && [_event.venue objectForKey:@"longitude"]) {
        [_itemsInSection2 addObject:[NSNumber numberWithInt:ATFbEventDetailItemMap]];
    }
    if (_event.description_ && [_event.description_ length] > 0) {
        [_itemsInSection3 addObject:[NSNumber numberWithInt:ATFbEventDetailItemDescription]];
        [_itemsInSection3 addObject:[NSNumber numberWithInt:ATFbEventDetailItemDescriptionContinue]];
    }
    [_itemsInSection4 addObject:[NSNumber numberWithInt:ATFbEventDetailItemStatus]];
    
    POOL_END;
}

- (ATFbEventDetailItem)eventDetailItemAtIndexPath:(NSIndexPath *)indexPath {
    ATFbEventDetailItem item = ATFbEventDetailItemNone;
    if (indexPath.section == 0) {
        item = [[_itemsInSection0 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 1) {
        item = [[_itemsInSection1 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 2) {
        item = [[_itemsInSection2 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 3) {
        item = [[_itemsInSection3 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 4) {
        item = [[_itemsInSection4 objectAtIndex:0] intValue];
    }
    return item;
}
 
- (UITableViewCell *)cellForIdentifier:(ATEventCellType)type tableView:(UITableView *)tv {
    static NSString *EventTextCell = @"EventTextCell";
    static NSString *EventDateCell = @"EventDateCell";
    static NSString *EventLabelTextCell = @"EventLabelTextCell";
    static NSString *EventMapCell = @"EventMapCell";
    static NSString *EventButtonCell = @"EventButtonCell";
    
    UITableViewCell *cell = nil;
    if (type == ATEventCellTypeText) {
        cell = [tv dequeueReusableCellWithIdentifier:EventTextCell];
        if (cell == nil) {
            cell = [[[ATEventTextCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:EventTextCell] autorelease];
        }
    } else if (type == ATEventCellTypeDate) {
        cell = [tv dequeueReusableCellWithIdentifier:EventDateCell];
        if (cell == nil) {
            cell = [[[ATEventDateCell alloc ] initWithStyle:UITableViewCellStyleDefault 
                                            reuseIdentifier:EventDateCell] autorelease];
        }
    } else if (type == ATEventCellTypeLabelText) {
        cell = [tv dequeueReusableCellWithIdentifier:EventLabelTextCell];
        if (cell == nil) {
            cell = [[[ATEventLabelTextCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:EventLabelTextCell] autorelease];
        }
    } else if (type == ATEventCellTypeMap) {
        cell = [tv dequeueReusableCellWithIdentifier:EventMapCell];
        if (cell == nil) {
            cell = [[[ATEventMapCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:EventMapCell] autorelease];
        }
    } else if (type == ATEventCellTypeButton) {
        cell = [tv dequeueReusableCellWithIdentifier:EventButtonCell];
        if (cell == nil) {
            cell = [[[TKButtonCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                        reuseIdentifier:EventButtonCell] autorelease];
        }
    }
    return cell;
}


- (void)addEkEventFacebook:(id)sender {
    POOL_START;
    NSDate *startDate = [NSDate dateConvertFromPstDate:
                         [NSDate dateWithTimeIntervalSince1970:[_event.start_time doubleValue]]];
    NSDate *endDate = [NSDate dateConvertFromPstDate:
                       [NSDate dateWithTimeIntervalSince1970:[_event.end_time doubleValue]]];
    if (!endDate) {
        endDate = [startDate dateByAddingTimeInterval:60*60];
    }
    
    [self addEkEvent:sender 
               title:_event.name 
            location:_event.location 
           startDate:startDate 
             endDate:endDate];
    POOL_END;
}

- (void)showEkEventFacebook:(id)sender {
    POOL_START;
    NSDate *startDate = [NSDate dateConvertFromPstDate:
                         [NSDate dateWithTimeIntervalSince1970:[_event.start_time doubleValue]]];
    NSDate *endDate = [NSDate dateConvertFromPstDate:
                       [NSDate dateWithTimeIntervalSince1970:[_event.end_time doubleValue]]];
    NSString *titleStart = [startDate stringForDispDateYmw];
    NSString *titleEnd = [endDate stringForDispDateYmw];
    
    NSString *titleString = nil;
    if (titleEnd && ![titleStart isEqualToString:titleEnd]) {
        titleString = [NSString stringWithFormat:@"%@ - %@", titleStart, titleEnd];
    } else {
        titleString = titleStart;
    }
    
    [self showEkEvent:sender 
            startDate:startDate 
              endDate:endDate
                title:titleString];
    POOL_END;
}

- (void)openMail:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    static NSString *bodyFormat = @""
    "<html>"
    "<head>"
    "</head>"
    "<body bgcolor='#FFFFFF'>"
    "<br/>"
    "<hr/>"
    "%@"
    "<br/>&nbsp;(from <a href='%@'>%@</a>)"
    "</body>"
    "</html>";
    
    NSString *subject = [NSString stringWithFormat:@"[Facebook]%@", _event.name];
    NSString *body = [NSString stringWithFormat:bodyFormat, 
                      [ATFbEventManager stringDivWithFbEvent:_event],
                      kAtndcalDownloadUrl,
                      [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"]
                      ];
    
    [self openMailWithSubject:subject body:body];
    POOL_END;
}

#pragma mark - Public

- (void)otherAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:_event.name] autorelease];
    [actionSheet addButtonWithTitle:@"ブラウザで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", fbMobileWebEventUrl, _event.id_];
        [self openWebView:sender url:urlString];
    }];
    [actionSheet addButtonWithTitle:@"Safariで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", fbMobileWebEventUrl, _event.id_];
        [self openSafari:sender url:urlString];
    }];
    [actionSheet addButtonWithTitle:@"その日の予定を見る" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self showEkEventFacebook:sender];
    }];
    [actionSheet addButtonWithTitle:@"カレンダーに登録" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self addEkEventFacebook:sender];
    }];
    if (self.bookmarkedIdentifier) {
        [actionSheet addButtonWithTitle:@"ブックマーク削除" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            [self removeBookmark:sender];
        }];
    } else {
        [actionSheet addButtonWithTitle:@"ブックマークする" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            [self addBookmark:sender type:ATEventTypeFacebook eventId:_event.id_];
        }];
    }
    if ([TWTweetComposeViewController canSendTweet]) {
        [actionSheet addButtonWithTitle:@"ツイートする" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@", fbWebEventUrl, _event.id_];
            NSURL *url = [NSURL URLWithString:urlString];
            NSString *initialText = [NSString stringWithFormat:@"\"%@:Facebook\" via ATND暦", _event.name];
            [self sendTweet:sender initialText:initialText url:url];
        }];
    }
    [actionSheet addButtonWithTitle:@"メール送信" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openMail:sender];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)dateAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *eventDateStart = [ATFbEventManager stringForDispDate:_event fbEventDate:ATFbEventDateStart];
    NSString *eventDateEnd = [ATFbEventManager stringForDispDate:_event fbEventDate:ATFbEventDateEnd];
    
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@", eventDateStart];
    if (eventDateEnd) {
        [title appendFormat:@" - %@", eventDateEnd];
    }
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:title] autorelease];
    [actionSheet addButtonWithTitle:@"その日の予定を見る" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self showEkEventFacebook:sender];
    }];
    [actionSheet addButtonWithTitle:@"カレンダーに登録" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self addEkEventFacebook:sender];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)placeAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *title = [NSString stringWithFormat:@"%@", _event.location];
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:title] autorelease];
    [actionSheet addButtonWithTitle:@"ブラウザで検索" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self searchByGoogle:sender keyword:title];
    }];
    [actionSheet addButtonWithTitle:@"マップで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openMap:sender keyword:title];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)addressAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *title = [NSString stringWithFormat:@"%@", _event.location];
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:title] autorelease];
    [actionSheet addButtonWithTitle:@"マップで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openMap:sender keyword:title];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];

    POOL_END;
}

- (void)mapAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *title = [NSString stringWithFormat:@"%@,%@", 
                       [_event.venue objectForKey:@"latitude"], 
                       [_event.venue objectForKey:@"longitude"]];
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:title] autorelease];
    [actionSheet addButtonWithTitle:@"マップで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openMap:sender keyword:title];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)textAction:(id)sender text:(NSString *)text {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"ブラウザで開く"] autorelease];

    NSArray *urls = [NSString arrayExtractUrlFromString:text];
    for (NSString *url in urls) {
        [actionSheet addButtonWithTitle:url callback:^(ATActionSheet *actionSheet, NSInteger index) {
            [self openWebView:sender url:url];
        }];
    }
    [actionSheet addButtonWithTitle:@"キーワード候補の抽出" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        ATTextAnalysisViewController *ctl = [[[ATTextAnalysisViewController alloc] init] autorelease];
        ctl.sentence = text;
        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
        [self presentModalViewController:nav animated:YES];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)reloadRsvpStatusAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    NSURLRequest *request = [fbConnecter requestSelectRsvpStatusOfEventId:_event.id_];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameFbRsvpStatusRequest
                                                                          request:request] 
                                     autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];

    POOL_END;
}

#pragma mark - Facebook Callback

- (void)notificationFbRsvpStatusRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successFbRsvpStatusRequest:userInfo];
    } else {
        [self errorFbRsvpStatusRequest:userInfo];
    }
}

- (void)successFbRsvpStatusRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSData *data = [userInfo objectForKey:kATRequestUserInfoReceivedData];
    NSString *jsonString = [[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding] autorelease];
    self.eventStatus = [ATFbEventStatusManager fbEventStatusWithJson:jsonString];
    [self.tableView reloadData];
    
    POOL_END;
}

- (void)errorFbRsvpStatusRequest:(NSDictionary *)userInfo {
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
