#import "ATEkEventViewController.h"
#import "ATCommon.h"

#import "ATEkEventCell.h"

@interface ATEkEventViewController ()
- (void)setupView;
- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(ATEkEventCell *)cell;
@end


@implementation ATEkEventViewController
@synthesize ekEvents = _ekEvents;
@synthesize titleViewString = _titleViewString;
@synthesize eventStore = _eventStore;
@synthesize defaultCalendar = _defaultCalendar;


- (void)dealloc {
    [_ekEvents release];
    [_titleViewString release];
    
    [_eventStore release];
    [_defaultCalendar release];
    [super dealloc];
}

- (void)loadView {
    LOG_CURRENT_METHOD;
    [super loadView];
    [self setupView];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _ekEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ATEkEventCell *cell = (ATEkEventCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ATEkEventCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    return [self setupCellForRowAtIndexPath:indexPath cell:cell];
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    
	[tv deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row < _ekEvents.count) {
        EKEvent *ekEvent = [_ekEvents objectAtIndex:indexPath.row];
        EKEventEditViewController *addController = [[[EKEventEditViewController alloc] init] autorelease];
        addController.editViewDelegate = self;
        addController.event = ekEvent;
        addController.eventStore = _eventStore;
        [self presentModalViewController:addController animated:YES];
    }
}

#pragma mark - Private

- (void)setupView {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"閉じる" 
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:self 
                                                                                 action:@selector(closeAction:)] autorelease];
    }
    ATTitleView *titleView = [[[ATTitleView alloc] init] autorelease];
    [titleView setTitle:_titleViewString];
    self.navigationItem.titleView = titleView;
    
    POOL_END;
}


- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(ATEkEventCell *)cell {
    
    EKEvent *ekEvent = [_ekEvents objectAtIndex:indexPath.row];
    [cell setEkEvent:ekEvent];
    return cell;
}

#pragma mark - Public

- (void)closeAction:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissModalViewControllerAnimated:YES];
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
			break;
		case EKEventEditViewActionSaved:
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			break;
		case EKEventEditViewActionDeleted:
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
            [_ekEvents removeObject:thisEvent];
            [self.tableView reloadData];
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
