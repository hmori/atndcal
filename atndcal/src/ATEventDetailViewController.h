#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "ATEventOutline.h"
#import "ATMailComposer.h"
#import "ATLwws.h"
#import "ATLwwsCell.h"

@class ATRssLdWeather;
@class ATTitleView;

typedef enum {
    ATEventCellTypeText,
    ATEventCellTypeDate,
    ATEventCellTypeLabelText,
    ATEventCellTypeMap,
    ATEventCellTypeLwws,
    ATEventCellTypeComment,
    ATEventCellTypeButton,
} ATEventCellType;

typedef enum {
    ATEventCellViewTagIndicator = 1,
} ATEventCellViewTag;


@interface ATEventDetailViewController : TKTableViewController <EKEventEditViewDelegate> {
  @private
    id _eventObject;
    NSString *_bookmarkedIdentifier;
    ATTitleView *_titleView;
    
    //EventKit
	EKEventStore *_eventStore;
	EKCalendar *_defaultCalendar;
    
    ATMailComposer *_mailComposer;
    
    ATLwws *_lwws;
    ATRssLdWeather *_rssLdWeather;
}
@property (nonatomic, readonly) NSString *bookmarkedIdentifier;
@property (nonatomic, retain) ATLwws *lwws;
@property (nonatomic, retain) ATRssLdWeather *rssLdWeather;


- (id)initWithEventObject:(id)eventObject;

- (NSString *)eventTitle;
- (void)setBookmarkedIdentifierWithEventId:(NSString *)eventId type:(ATEventType)type;

- (void)openWebView:(id)sender url:(NSString *)urlString;
- (void)openSafari:(id)sender url:(NSString *)urlString;
- (void)openMap:(id)sender keyword:(NSString *)keyword;
- (void)searchByGoogle:(id)sender keyword:(NSString *)keyword;
- (void)addEkEvent:(id)sender 
             title:(NSString *)title 
          location:(NSString *)location 
         startDate:(NSDate *)startDate 
           endDate:(NSDate *)endDate;
- (void)showEkEvent:(id)sender 
          startDate:(NSDate *)startDate 
            endDate:(NSDate *)endDate 
              title:(NSString *)title;
- (void)addBookmark:(id)sender type:(ATEventType)type eventId:(NSString *)eventId;
- (void)removeBookmark:(id)sender;
- (void)sendTweet:(id)sender initialText:(NSString *)initialText url:(NSURL *)url;
- (void)openMailWithSubject:(NSString *)subject body:(NSString *)body;
- (void)requestLwws:(NSString *)address 
           location:(CLLocation *)location 
          startDate:(NSDate *)startDate 
            endDate:(NSDate *)endDate 
   searchCandidates:(NSArray *)searchCandidates;
- (UIActivityIndicatorView *)indicatorViewForCellImage;
- (void)settingLwwsCell:(ATLwwsCell *)cell;
- (void)selectTimerForNotification:(id)sender message:(NSString *)message startDate:(NSDate *)startDate;


@end
