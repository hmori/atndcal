#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "ATTableData.h"

typedef enum {
    ATTableViewTagIndicator = 1,
} ATTableViewTag;

@interface ATTableViewController : TKTableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *_data;
}
@property (nonatomic, retain) NSArray *data;

- (void)setupTitle;
- (void)setupView;
- (CGSize)sizeImageForCell;
- (CGFloat)cornerRadiusImageForCell;
- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell;
- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Overwride
- (NSString *)titleString;
- (void)setupCellData;


@end
