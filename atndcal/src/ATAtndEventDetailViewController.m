//
//  ATAtndEventDetailViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATAtndEventDetailViewController.h"
#import <Twitter/Twitter.h>
#import "ATCommon.h"

#import "ATEventDateCell.h"
#import "ATEventTextCell.h"
#import "ATEventLabelTextCell.h"
#import "ATEventMapCell.h"
#import "ATLwwsCell.h"
#import "ATEventCommentCell.h"

#import "ATAttendeeViewController.h"
#import "ATWebViewController.h"
#import "ATProfileViewController.h"
#import "ATTextAnalysisViewController.h"
#import "ATSettingEvernoteViewController.h"

#import "ATRssParser.h"
#import "ATRssLdWeather.h"

typedef enum {
    ATAtndEventDetailItemNone,
    ATAtndEventDetailItemCatch,
    ATAtndEventDetailItemDate,
    ATAtndEventDetailItemCapacity,
    ATAtndEventDetailItemOwner,
    ATAtndEventDetailItemPlace,
    ATAtndEventDetailItemAddress,
    ATAtndEventDetailItemMap,
    ATAtndEventDetailItemUrl,
    ATAtndEventDetailItemDescription,
    ATAtndEventDetailItemDescriptionContinue,
    ATAtndEventDetailItemEntry,
    ATAtndEventDetailItemLwws,
    ATAtndEventDetailItemComment
} ATAtndEventDetailItem;

@interface ATAtndEventDetailViewController ()
@property (nonatomic, retain) ATEvent *event;
@property (nonatomic, retain) NSArray *commentItems;
@property (nonatomic, retain) NSMutableArray *itemsInSection0;
@property (nonatomic, retain) NSMutableArray *itemsInSection1;
@property (nonatomic, retain) NSMutableArray *itemsInSection2;
@property (nonatomic, retain) NSMutableArray *itemsInSection3;
@property (nonatomic, retain) NSMutableArray *itemsInSection4;
@property (nonatomic, retain) NSMutableArray *itemsInSection5;
@property (nonatomic, retain) NSMutableArray *itemsInSection6;

- (void)initATAtndEventDetailViewController;
- (void)setupItems;
- (ATAtndEventDetailItem)eventDetailItemAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForIdentifier:(ATEventCellType)type tableView:(UITableView *)tv;
- (void)addEkEventAtnd:(id)sender;
- (void)showEkEventAtnd:(id)sender;
- (void)openMail:(id)sender;
- (void)clipEvernote:(id)sender;

- (void)successEventCommentRequest:(NSDictionary *)userInfo;
- (void)errorEventCommentRequest:(NSDictionary *)userInfo;
@end


@implementation ATAtndEventDetailViewController
@synthesize event = _event;
@synthesize commentItems = _commentItems;
@synthesize itemsInSection0 = _itemsInSection0;
@synthesize itemsInSection1 = _itemsInSection1;
@synthesize itemsInSection2 = _itemsInSection2;
@synthesize itemsInSection3 = _itemsInSection3;
@synthesize itemsInSection4 = _itemsInSection4;
@synthesize itemsInSection5 = _itemsInSection5;
@synthesize itemsInSection6 = _itemsInSection6;

static NSString *atndWebEventUrl = @"http://atnd.org/events/";
static NSString *atndRssEventCommenturl = @"http://atnd.org/comments/%@.rss";

- (id)initWithEventObject:(id)eventObject {
    LOG_CURRENT_METHOD;
    self = [super initWithEventObject:eventObject];
    if (self) {
        POOL_START;
        self.event = [ATEventManager eventWithEventObject:eventObject];
        [self initATAtndEventDetailViewController];
        POOL_END;
    }
    return self;
}

- (void)initATAtndEventDetailViewController {
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationEventCommentRequest:) 
                                                 name:ATNotificationNameEventCommentRequest 
                                               object:nil];
    [self setBookmarkedIdentifierWithEventId:_event.event_id type:ATEventTypeAtnd];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_event release];
    [_commentItems release];
    [_itemsInSection0 release];
    [_itemsInSection1 release];
    [_itemsInSection2 release];
    [_itemsInSection3 release];
    [_itemsInSection4 release];
    [_itemsInSection5 release];
    [_itemsInSection6 release];
    [super dealloc];
}

#pragma mark - Setter

- (void)setEvent:(ATEvent *)event {
    LOG_CURRENT_METHOD;
    if (_event != event) {
        [_event release];
        _event = [event retain];
        
        [self setupItems];
    }
}

#pragma mark - View lifecycle


- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    [self reloadCommentAction:nil];
    [self reloadLwwsAction:nil];
}

#pragma mark - Overwride ATEventDetailViewController

- (NSString *)eventTitle {
    return _event.title;
}


#pragma mark - TableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
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
    } else if (section == 5) {
        if (self.lwws) {
            row = _itemsInSection5.count;
        }
    } else if (section == 6) {
        row = _commentItems.count;
    }
	return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    
    ATAtndEventDetailItem item = [self eventDetailItemAtIndexPath:indexPath];
    if (item == ATAtndEventDetailItemNone) {
        height = 0.0f;
    } else if (item == ATAtndEventDetailItemCatch) {
        height = [ATEventTextCell heightCellOfLabelText:_event.catch_ 
                                                   truncate:NO];
    } else if (item == ATAtndEventDetailItemMap) {
        height = [ATEventMapCell heightCell];
    } else if (item == ATAtndEventDetailItemDescription) {
        height = [ATEventTextCell heightCellOfLabelText:[ATEventManager stringForDispDescription:_event] 
                                                   truncate:!_isContinueDescription];
    } else if (item == ATAtndEventDetailItemLwws) {
        NSString *text = [ATLwwsManager stringForDispDescription:self.lwws];
        height = [ATLwwsCell heightCellOfLabelText:text 
                                          truncate:NO];
    } else if (item == ATAtndEventDetailItemComment) {
        NSString *text = [[_commentItems objectAtIndex:indexPath.row] description_];
        height = [ATEventCommentCell heightCellOfLabelText:text 
                                                  truncate:NO];
    }
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSString *title1 = @"場所";
    static NSString *title3 = @"詳細";
    static NSString *title4 = @"出席";
    static NSString *title6 = @"コメント";
    NSString *title = nil;
    if (section == 0) {
        title = _event.title;
    } else if (section == 1) {
        title = title1;
    } else if (section == 3) {
        title = title3;
    } else if (section == 4) {
        title = title4;
    } else if (section == 5) {
        if (self.lwws) {
            title = self.lwws.title;
        }
    } else if (section == 6) {
        title = title6;
    }
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    static NSString *title5 = @"powered by Livedoor Weather Hacks";
    NSString *title = nil;
    if (section == 5) {
        if (self.lwws) {
            title = title5;
        }
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    ATAtndEventDetailItem item = [self eventDetailItemAtIndexPath:indexPath];
    if (item == ATAtndEventDetailItemNone) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    } else if (item == ATAtndEventDetailItemCatch) {
        cell = [self cellForIdentifier:ATEventCellTypeText tableView:tv];
        ATEventTextCell *c = (ATEventTextCell *)cell;
        c.field.text = _event.catch_;
        c.truncate = NO;
    } else if (item == ATAtndEventDetailItemDate) {
        NSString *eventDateStart = [ATEventManager stringForDispDate:_event eventDate:ATEventDateStart];
        NSString *eventDateEnd = [ATEventManager stringForDispDate:_event eventDate:ATEventDateEnd];
        
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
    } else if (item == ATAtndEventDetailItemCapacity) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"定員";
        c.field.text = [ATEventManager stringForDispCapacity:_event];
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (item == ATAtndEventDetailItemOwner) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"主催者";
        c.field.text = _event.owner_nickname;
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (item == ATAtndEventDetailItemPlace) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"会場";
        c.field.text = _event.place;
    } else if (item == ATAtndEventDetailItemAddress) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        c.label.text = @"住所";
        c.field.text = _event.address;
    } else if (item == ATAtndEventDetailItemMap) {
        cell = [self cellForIdentifier:ATEventCellTypeMap tableView:tv];
        ATEventMapCell *c = (ATEventMapCell *)cell;
        if ((NSNull *)_event.lat != [NSNull null] && (NSNull *)_event.lon != [NSNull null]) {
            CLLocationCoordinate2D location;
            location.latitude = [_event.lat doubleValue];
            location.longitude = [_event.lon doubleValue];
            [c setLocation:location];
        }
    } else if (item == ATAtndEventDetailItemUrl) {
        cell = [self cellForIdentifier:ATEventCellTypeLabelText tableView:tv];
        ATEventLabelTextCell *c = (ATEventLabelTextCell *)cell;
        if ((NSNull *)_event.url != [NSNull null]) {
            c.label.text = @"Web";
            c.field.text = _event.url;
        }
    } else if (item == ATAtndEventDetailItemDescription) {
        cell = [self cellForIdentifier:ATEventCellTypeText tableView:tv];
        ATEventTextCell *c = (ATEventTextCell *)cell;
        c.field.text = [ATEventManager stringForDispDescription:_event];
        c.truncate = !_isContinueDescription;
    } else if (item == ATAtndEventDetailItemDescriptionContinue) {
        cell = [self cellForIdentifier:ATEventCellTypeButton tableView:tv];
        TKButtonCell *c = (TKButtonCell *)cell;
        c.textLabel.text = _isContinueDescription?@"閉じる":@"続きを読む";
    } else if (item == ATAtndEventDetailItemEntry) {
        cell = [self cellForIdentifier:ATEventCellTypeButton tableView:tv];
        TKButtonCell *c = (TKButtonCell *)cell;
        c.textLabel.text = @"出席の申し込み";
    } else if (item == ATAtndEventDetailItemLwws) {
        cell = [self cellForIdentifier:ATEventCellTypeLwws tableView:tv];
        [self settingLwwsCell:(ATLwwsCell *)cell];
    } else if (item == ATAtndEventDetailItemComment) {
        cell = [self cellForIdentifier:ATEventCellTypeComment tableView:tv];
        ATEventCommentCell *c = (ATEventCommentCell *)cell;
        c.label.text = [[_commentItems objectAtIndex:indexPath.row] author];
        NSString *pubDate = [[_commentItems objectAtIndex:indexPath.row] pubDate];
        c.pubDateLabel.text = [ATRssItemManager stringForDispPubDate:pubDate];
        c.field.text = [ATRssItemManager stringForDispDescription:[[_commentItems objectAtIndex:indexPath.row] description_]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    
	[tv deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *controller = nil;
    
    ATAtndEventDetailItem item = [self eventDetailItemAtIndexPath:indexPath];
    if (item == ATAtndEventDetailItemNone) {
    } else if (item == ATAtndEventDetailItemCatch) {
        [self textAction:nil text:_event.catch_];
    } else if (item == ATAtndEventDetailItemDate) {
        [self dateAction:nil];
    } else if (item == ATAtndEventDetailItemCapacity) {
        controller = [[[ATAttendeeViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        [(ATAttendeeViewController *)controller setEvent:_event];
    } else if (item == ATAtndEventDetailItemOwner) {
        controller = [[[ATProfileViewController alloc] init] autorelease];
        ((ATProfileViewController *)controller).userId = _event.owner_id;
    } else if (item == ATAtndEventDetailItemPlace) {
        [self placeAction:nil];
    } else if (item == ATAtndEventDetailItemAddress) {
        [self addressAction:nil];
    } else if (item == ATAtndEventDetailItemUrl) {
        [self urlAction:nil];
    } else if (item == ATAtndEventDetailItemMap) {
        [self mapAction:nil];
    } else if (item == ATAtndEventDetailItemDescription) {
        [self textAction:nil text:[ATEventManager stringForDispDescription:_event]];
    } else if (item == ATAtndEventDetailItemDescriptionContinue) {
        _isContinueDescription = !_isContinueDescription;
        [tv reloadData];
    } else if (item == ATAtndEventDetailItemEntry) {
        [self entryAction:nil];
    } else if (item == ATAtndEventDetailItemLwws) {
        if (self.rssLdWeather.source) {
            controller = [[[ATWebViewController alloc] initWithUrlString:self.rssLdWeather.source] autorelease];
        }
    } else if (item == ATAtndEventDetailItemComment) {
        //TODO:
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
    self.itemsInSection5 = [NSMutableArray arrayWithCapacity:0];
    self.itemsInSection6 = [NSMutableArray arrayWithCapacity:0];
    
    if (_event.catch_ && [_event.catch_ length] > 0) {
        [_itemsInSection0 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemCatch]];
    }
    [_itemsInSection0 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemDate]];
    [_itemsInSection0 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemCapacity]];
    if (_event.owner_nickname && [_event.owner_nickname length] > 0) {
        [_itemsInSection0 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemOwner]];
    }
    if (_event.place && [_event.place length] > 0) {
        [_itemsInSection1 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemPlace]];
    }
    if (_event.address && [_event.address length] > 0) {
        [_itemsInSection1 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemAddress]];
    }
    if ((NSNull *)_event.url != [NSNull null] && _event.url && [_event.url length] > 0) {
        [_itemsInSection1 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemUrl]];
    }
    if ((NSNull *)_event.lat != [NSNull null] && (NSNull *)_event.lon != [NSNull null]) {
        [_itemsInSection2 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemMap]];
    }
    if (_event.description_ && [_event.description_ length] > 0) {
        [_itemsInSection3 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemDescription]];
        [_itemsInSection3 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemDescriptionContinue]];
    }
    [_itemsInSection4 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemEntry]];
    [_itemsInSection5 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemLwws]];
    [_itemsInSection6 addObject:[NSNumber numberWithInt:ATAtndEventDetailItemComment]];
    
    POOL_END;
}

- (ATAtndEventDetailItem)eventDetailItemAtIndexPath:(NSIndexPath *)indexPath {
    ATAtndEventDetailItem item = ATAtndEventDetailItemNone;
    if (indexPath.section == 0) {
        item = [[_itemsInSection0 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 1) {
        item = [[_itemsInSection1 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 2) {
        item = [[_itemsInSection2 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 3) {
        item = [[_itemsInSection3 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 4) {
        item = [[_itemsInSection4 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 5) {
        item = [[_itemsInSection5 objectAtIndex:indexPath.row] intValue];
    } else if (indexPath.section == 6) {
        item = [[_itemsInSection6 objectAtIndex:0] intValue];
    }
    return item;
}

- (UITableViewCell *)cellForIdentifier:(ATEventCellType)type tableView:(UITableView *)tv {
    static NSString *EventTextCell = @"EventTextCell";
    static NSString *EventDateCell = @"EventDateCell";
    static NSString *EventLabelTextCell = @"EventLabelTextCell";
    static NSString *EventMapCell = @"EventMapCell";
    static NSString *EventCommentCell = @"EventCommentCell";
    static NSString *LwwsCell = @"LwwsCell";
    static NSString *ButtonCell = @"ButtonCell";
    
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
    } else if (type == ATEventCellTypeComment) {
        cell = [tv dequeueReusableCellWithIdentifier:EventCommentCell];
        if (cell == nil) {
            cell = [[[ATEventCommentCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                              reuseIdentifier:EventCommentCell] autorelease];
        }
    } else if (type == ATEventCellTypeLwws) {
        cell = [tv dequeueReusableCellWithIdentifier:LwwsCell];
        if (cell == nil) {
            cell = [[[ATLwwsCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:LwwsCell] autorelease];
        }
    } else if (type == ATEventCellTypeButton) {
        cell = [tv dequeueReusableCellWithIdentifier:ButtonCell];
        if (cell == nil) {
            cell = [[[TKButtonCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                        reuseIdentifier:ButtonCell] autorelease];
        }
    }
    return cell;
}

- (void)addEkEventAtnd:(id)sender {
    POOL_START;
    NSDate *startDate = [NSDate dateForAtndDateString:_event.started_at];
    NSDate *endDate = nil;
    if ((NSNull *)_event.ended_at != [NSNull null]) {
        endDate = [NSDate dateForAtndDateString:_event.ended_at];
    } else {
        endDate = [[NSDate dateForAtndDateString:_event.started_at] dateByAddingTimeInterval:60*60];
    }
    
    [self addEkEvent:sender 
               title:_event.title 
            location:_event.place 
           startDate:startDate 
             endDate:endDate];
    POOL_END;
}

- (void)showEkEventAtnd:(id)sender {
    POOL_START;
    NSDate *startDate = [NSDate dateForAtndDateString:_event.started_at];
    NSDate *endDate = [NSDate dateForAtndDateString:_event.ended_at];
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
    
    NSString *subject = [NSString stringWithFormat:@"[ATND]%@", _event.title];
    NSString *body = [NSString stringWithFormat:bodyFormat, 
                      [ATEventManager stringDivWithEvent:_event],
                      kAtndcalDownloadUrl,
                      [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"]
                      ];
    
    [self openMailWithSubject:subject body:body];
    POOL_END;
}

- (void)clipEvernote:(id)sender {
    LOG_CURRENT_METHOD;
    
    NSString *title = [NSString stringWithFormat:@"[ATND]%@", _event.title];
    NSString *divContent = [ATEventManager stringDivWithEvent:_event];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", atndWebEventUrl, _event.event_id];

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:title forKey:@"title"];
    [param setObject:divContent forKey:@"divContent"];
    [param setObject:@"ATND" forKey:@"tags"];
    [param setObject:urlString forKey:@"sourceURL"];
    
    BOOL isSuccess = [[ATEvernoteConnecter sharedATEvernoteConnecter] createNote:param];
    if (isSuccess) {
        [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) 
                                                        withObject:@"クリップしました." 
                                                     waitUntilDone:YES];
    }
}

#pragma mark - Public

- (void)otherAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:_event.title] autorelease];
    [actionSheet addButtonWithTitle:@"ブラウザで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", atndWebEventUrl, _event.event_id];
        [self openWebView:sender url:urlString];
    }];
    [actionSheet addButtonWithTitle:@"Safariで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", atndWebEventUrl, _event.event_id];
        [self openSafari:sender url:urlString];
    }];
    [actionSheet addButtonWithTitle:@"その日の予定を見る" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self showEkEventAtnd:sender];
    }];
    [actionSheet addButtonWithTitle:@"カレンダーに登録" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self addEkEventAtnd:sender];
    }];
    if (self.bookmarkedIdentifier) {
        [actionSheet addButtonWithTitle:@"ブックマーク削除" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            [self removeBookmark:sender];
        }];
    } else {
        [actionSheet addButtonWithTitle:@"ブックマークする" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            [self addBookmark:sender type:ATEventTypeAtnd eventId:_event.event_id];
        }];
    }
    [actionSheet addButtonWithTitle:@"事前に通知する" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        static NSString *messageFormat = @"%@ : [%@] @ %@";
        NSString *message = [NSString stringWithFormat:messageFormat, 
                             _event.title, 
                             [ATEventManager stringForDispDate:_event],
                             _event.place];
        NSDate *startDate = [NSDate dateForAtndDateString:_event.started_at];
        [self selectTimerForNotification:sender message:message startDate:startDate];
    }];
    
    [actionSheet addButtonWithTitle:@"Evernoteにクリップ" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *evernoteUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEvernoteUsername];
        if (evernoteUsername) {
            NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] 
                                                    initWithTarget:self 
                                                    selector:@selector(clipEvernote:) 
                                                    object:sender] autorelease];
            invOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
            [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
        } else {
            ATSettingEvernoteViewController *ctl = [[[ATSettingEvernoteViewController alloc] init] autorelease];
            UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
            [self presentModalViewController:nav animated:YES];
        }

    }];
    
    if ([TWTweetComposeViewController canSendTweet]) {
        [actionSheet addButtonWithTitle:@"ツイートする" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@", atndWebEventUrl, _event.event_id];
            NSURL *url = [NSURL URLWithString:urlString];
            NSString *initialText = [NSString stringWithFormat:@"\"%@\" via ATND暦", _event.title];
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
    
    NSString *eventDateStart = [ATEventManager stringForDispDate:_event eventDate:ATEventDateStart];
    NSString *eventDateEnd = [ATEventManager stringForDispDate:_event eventDate:ATEventDateEnd];
    
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@", eventDateStart];
    if (eventDateEnd) {
        [title appendFormat:@" - %@", eventDateEnd];
    }
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:title] autorelease];
    [actionSheet addButtonWithTitle:@"その日の予定を見る" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self showEkEventAtnd:sender];
    }];
    [actionSheet addButtonWithTitle:@"カレンダーに登録" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self addEkEventAtnd:sender];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:self.view];

    POOL_END;
}

- (void)placeAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *title = [NSString stringWithFormat:@"%@", _event.place];
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
    
    NSString *title = [NSString stringWithFormat:@"%@", _event.address];
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
    
    NSString *title = [NSString stringWithFormat:@"%@,%@", _event.lat, _event.lon];
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:title] autorelease];
    [actionSheet addButtonWithTitle:@"マップで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openMap:sender keyword:title];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)urlAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:_event.url] autorelease];
    [actionSheet addButtonWithTitle:@"ブラウザで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openWebView:sender url:_event.url];
    }];
    [actionSheet addButtonWithTitle:@"Safariで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openSafari:sender url:_event.url];
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
            LOG(@"url=%@", url);
            [self openWebView:sender url:url];
        }];
    }
    [actionSheet addButtonWithTitle:@"検索キーワード候補" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        ATTextAnalysisViewController *ctl = [[[ATTextAnalysisViewController alloc] init] autorelease];
        ctl.sentence = text;
        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
        [self presentModalViewController:nav animated:YES];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)entryAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"ATNDの出席申し込みはWebブラウザを利用する必要があります"] autorelease];
    [actionSheet addButtonWithTitle:@"ブラウザで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@/entry/new", atndWebEventUrl, _event.event_id];
        [self openWebView:sender url:urlString];
    }];
    [actionSheet addButtonWithTitle:@"Safariで開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@/entry/new", atndWebEventUrl, _event.event_id];
        [self openSafari:sender url:urlString];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    POOL_END;
}

- (void)reloadCommentAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *url = [NSString stringWithFormat:atndRssEventCommenturl, _event.event_id];
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0f] autorelease];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameEventCommentRequest
                                                                          request:request] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}

- (void)reloadLwwsAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    CLLocation *location = nil;
    if ((NSNull *)_event.lat != [NSNull null] && (NSNull *)_event.lon != [NSNull null]) {
        location = [[[CLLocation alloc] initWithLatitude:[_event.lat doubleValue] 
                                               longitude:[_event.lon doubleValue]] autorelease];
    }
    NSDate *startDate = [NSDate dateForAtndDateString:_event.started_at];
    NSDate *endDate = [NSDate dateForAtndDateString:_event.ended_at];
    
    NSMutableArray *searchCandidates = [NSMutableArray arrayWithCapacity:0];
    if (_event.place && (NSNull *)_event.place != [NSNull null]) {
        [searchCandidates addObject:_event.place];
    }
    if (_event.title && (NSNull *)_event.title != [NSNull null]) {
        [searchCandidates addObject:_event.title];
    }
    if (_event.catch_ && (NSNull *)_event.catch_ != [NSNull null]) {
        [searchCandidates addObject:_event.catch_];
    }
    if (_event.description_ && (NSNull *)_event.description_ != [NSNull null]) {
        [searchCandidates addObject:_event.description_];
    }
    
    [self requestLwws:_event.address 
             location:location 
            startDate:startDate 
              endDate:endDate
     searchCandidates:searchCandidates];
    
    POOL_END;
}



#pragma mark - Event Comment Request Callback

- (void)notificationEventCommentRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successEventCommentRequest:userInfo];
    } else {
        [self errorEventCommentRequest:userInfo];
    }
}

- (void)successEventCommentRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSData *data = [userInfo objectForKey:kATRequestUserInfoReceivedData];
    ATRssParser *parser = [[[ATRssParser alloc] init] autorelease];
    [parser parse:data];
    self.commentItems = parser.items;
    [self.tableView reloadData];
    
    POOL_END;
}

- (void)errorEventCommentRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSString *message = [NSString stringWithFormat:@"ATND Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameEventCommentRequest];
    
    POOL_END;
}


@end
