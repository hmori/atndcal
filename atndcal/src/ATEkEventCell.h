#import <UIKit/UIKit.h>

#import <TapkuLibrary/TapkuLibrary.h>
#import <eventkit/EventKit.h>
#import <eventkitui/EventKitUI.h>

@interface ATEkEventCell : TKIndicatorCell {
    EKEvent *_ekEvent;
}
@property (nonatomic, retain) EKEvent *ekEvent;

@end
