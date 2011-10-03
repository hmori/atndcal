//
//  ATEkEventViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEkEventViewController.h"
#import "ATCommon.h"

#import "ATTitleView.h"
#import "ATEkEventCell.h"

@interface ATEkEventViewController ()
- (void)setupView;
- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(ATEkEventCell *)cell;
@end


@implementation ATEkEventViewController

@synthesize ekEvents = _ekEvents;
@synthesize titleViewString = _titleViewString;

- (void)dealloc {
    [_ekEvents release];
    [_titleViewString release];
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
    
    UIView *spaceView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)] autorelease];
    UIBarButtonItem *fixedItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceView] autorelease];
    self.navigationItem.rightBarButtonItem = fixedItem;

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

@end
