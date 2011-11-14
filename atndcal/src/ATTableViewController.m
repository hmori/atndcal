#import "ATTableViewController.h"
#import "ATCommon.h"

#import "ATCalendarTableViewController.h"
#import "UIImage+ATCategory.h"

@interface ATTableViewController ()
- (void)initATTableViewController;
- (UIActivityIndicatorView *)indicatorViewForCellImage;
- (void)layoutImageForCell:(UITableViewCell *)cell;
@end


@implementation ATTableViewController
@synthesize data = _data;

static NSString * const newImage = NewImageCenterImage;

- (id)init {
    if ((self = [super init])) {
        [self initATTableViewController];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATTableViewController];
    }
    return self;
}

- (void)initATTableViewController {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(newImageRetrieved) 
                                                 name:newImage 
                                               object:nil];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:newImage object:nil];

    [_data release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView {
    LOG_CURRENT_METHOD;
    [super loadView];
    
    [self setupTitle];
    [self setupView];
    self.title = [self titleString];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    
    [self setupCellData];
}

- (void)viewDidUnload {
    LOG_CURRENT_METHOD;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    LOG_CURRENT_METHOD;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_data objectAtIndex:section] rows] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[_data objectAtIndex:section] title];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [[_data objectAtIndex:section] footer];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    return [self setupCellForRowAtIndexPath:indexPath cell:cell];
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
	[tv deselectRowAtIndexPath:indexPath animated:YES];
    [self actionDidSelectRowAtIndexPath:indexPath];
}

#pragma mark - Observer

- (void)newImageRetrieved {
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ATTableData *tableData = [_data objectAtIndex:indexPath.section];
        NSArray *imageUrls = [tableData imageUrls];
        NSString *imageUrl = [imageUrls objectAtIndex:indexPath.row];
        UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:imageUrl queueIfNeeded:NO];
        
        if(image){
            [[cell.imageView viewWithTag:ATTableViewTagIndicator] removeFromSuperview];
            cell.imageView.image = image;
            [self layoutImageForCell:cell];
            [cell setNeedsLayout];
        }
	}
}

#pragma mark - Private

- (UIActivityIndicatorView *)indicatorViewForCellImage {
    UIActivityIndicatorView *indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    indicatorView.frame = CGRectMake(0.0f,0.0f,30.0f, 30.0f);
    indicatorView.contentMode = UIViewContentModeCenter;
    indicatorView.userInteractionEnabled = NO;
    indicatorView.tag = ATTableViewTagIndicator;
    [indicatorView startAnimating];
    return indicatorView;
}

- (void)layoutImageForCell:(UITableViewCell *)cell {
    POOL_START;
    cell.imageView.image = [cell.imageView.image imageScaledToSize:[self sizeImageForCell]];
    CGFloat cornerRadius = [self cornerRadiusImageForCell];
    if (cornerRadius > 0) {
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = cornerRadius;
    }
    POOL_END;
}

#pragma mark - Public

- (void)setupTitle {
    POOL_START;
    ATTitleView *titleView = [[[ATTitleView alloc] init] autorelease];
    [titleView setTitle:[self titleString]];
    self.navigationItem.titleView = titleView;
    
    self.title = [self titleString];
    POOL_END;
}

- (void)setupView {
}

- (CGSize)sizeImageForCell {
    return CGSizeMake(30.0f, 30.0f);
}

- (CGFloat)cornerRadiusImageForCell {
    return 8.0f;
}

- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    
    static NSString *httpPrefix = @"http://";
    static NSString *httpsPrefix = @"https://";
    
    ATTableData *tableData = [_data objectAtIndex:indexPath.section];

	cell.textLabel.text = nil;
    NSArray *rows = [tableData rows];
    if (indexPath.row < rows.count) {
        NSString *text = [rows objectAtIndex:indexPath.row];
        if ((NSNull *)text != [NSNull null]) {
            cell.textLabel.text = text;
        }
    }

    cell.detailTextLabel.text = nil;
    NSArray *detailRows = [tableData detailRows];
    if (indexPath.row < detailRows.count) {
        NSString *detailText = [detailRows objectAtIndex:indexPath.row];
        if ((NSNull *)detailText != [NSNull null]) {
            cell.detailTextLabel.text = detailText;
        }
    }
    
    cell.imageView.image = nil;
    for (UIView *view in [cell.imageView subviews]) {
        [view removeFromSuperview];
    }

    NSArray *images = [tableData images];
    UIImage *image = nil;
    if (indexPath.row < images.count) {
        image = [images objectAtIndex:indexPath.row];
    }

    NSArray *imageUrls = [tableData imageUrls];
    NSString *imageUrl = nil;
    if (indexPath.row < imageUrls.count) {
        imageUrl = [imageUrls objectAtIndex:indexPath.row];
    }

    if (image && (NSNull *)image != [NSNull null]) {
        cell.imageView.image = image;
    } else if (imageUrl && (NSNull *)imageUrl != [NSNull null]) {
        if ([imageUrl hasPrefix:httpPrefix] || [imageUrl hasPrefix:httpsPrefix]) {
            UIImage *i = [[TKImageCenter sharedImageCenter] imageAtURL:imageUrl queueIfNeeded:YES];
            if (!i) {
                cell.imageView.image = [[[UIImage alloc] init] autorelease];
                [cell.imageView addSubview:[self indicatorViewForCellImage]];
            } else {
                cell.imageView.image = i;
            }
        } else {
            cell.imageView.image = [UIImage imageWithContentsOfFile:imageUrl];
        }
    }
    if (cell.imageView.image) {
        [self layoutImageForCell:cell];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSArray *pushControllers = [tableData pushControllers];
    if (indexPath.row < pushControllers.count) {
        Class controllerClass = (Class)[pushControllers objectAtIndex:indexPath.row];
        if (pushControllers && (NSNull *)controllerClass != [NSNull null]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    NSArray *accessorys = [tableData accessorys];
    if (indexPath.row < accessorys.count) {
        NSNumber *accessoryType = [accessorys objectAtIndex:indexPath.row];
        if ((NSNull *)accessoryType != [NSNull null]) {
            cell.accessoryType = [accessoryType integerValue];
        }
    }
    
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *pushControllers = [[_data objectAtIndex:indexPath.section] pushControllers];
    Class controllerClass = (Class)[pushControllers objectAtIndex:indexPath.row];
    if ((NSNull *)controllerClass != [NSNull null]) {
        UIViewController *controller = [[[controllerClass alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Overwride methods

- (NSString *)titleString {
    return @"Overwride titleString";
}

- (void)setupCellData {
    POOL_START;

    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
	
    d = [ATTableData tableData];
    d.rows = [NSArray arrayWithObjects:@"Overwride row",nil];
    d.pushControllers = [NSArray arrayWithObjects:[NSNull null], nil];
    d.title = @"Overwride Header Title";
    d.footer = @"Overwride footer";
	[tmp addObject:d];
	[tmp addObject:d];
	
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    POOL_END;
}


@end

