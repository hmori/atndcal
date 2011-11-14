#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface ATEventDateCell : TKLabelFieldCell {
    UILabel *_startField;
    UILabel *_endField;
}
@property (nonatomic, retain) UILabel *startField;
@property (nonatomic, retain) UILabel *endField;

@end
