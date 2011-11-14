#import "ATSettingSingleSelectViewController.h"
#import "ATCommon.h"

@interface ATSettingSingleSelectViewController ()
- (NSString *)keyForValueOfUserDefaults;
- (NSString *)stringForHeader;
- (NSString *)stringForFooter;
@end

@implementation ATSettingSingleSelectViewController

#pragma mark - Overwride

- (NSString *)titleString {
    NSString *title = nil;
    ATSetting *setting = [ATSetting sharedATSetting];
    title = (NSString *)[setting objectForItemKey:@"Title" 
                                              key:[self keyForValueOfUserDefaults]];
    return title;
}

- (void)setupView {
    POOL_START;
    UIView *spaceView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)] autorelease];
    UIBarButtonItem *fixedItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceView] autorelease];
    self.navigationItem.rightBarButtonItem = fixedItem;
    POOL_END;
}

- (void)setupCellData {
    LOG_CURRENT_METHOD;
    POOL_START;
    
	NSMutableArray *tmp = [NSMutableArray array];
    ATTableData *d = [ATTableData tableData];
    NSArray *titles = [[ATSetting sharedATSetting] arrayForTitlesOfKey:[self keyForValueOfUserDefaults]];
    d.rows = [NSMutableArray arrayWithArray:titles];
    d.title = [self stringForHeader];
    d.footer = [self stringForFooter];
	[tmp addObject:d];
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    POOL_END;
}


- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    LOG_CURRENT_METHOD;
    [super setupCellForRowAtIndexPath:indexPath cell:cell];
    
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForValueOfUserDefaults]];
    NSUInteger index = [[ATSetting sharedATSetting] indexOfValue:value key:[self keyForValueOfUserDefaults]];
    if (indexPath.row == index) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    NSArray *values = [[ATSetting sharedATSetting] arrayForValuesOfKey:[self keyForValueOfUserDefaults]];
    NSNumber *value = [values objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:[self keyForValueOfUserDefaults]];
    [defaults synchronize];
    
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    POOL_END;
}

#pragma mark - Public

- (NSString *)keyForValueOfUserDefaults {
    return nil;
}

- (NSString *)stringForHeader {
    return nil;
}

- (NSString *)stringForFooter {
    return nil;
}

@end
