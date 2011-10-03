//
//  ATEventBookmarkViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventBookmarkViewController.h"

#import "ATEventOutlineCell.h"

#import "ATEventForBookmark.h"

#import "ATAtndEventDetailViewController.h"
#import "ATFbEventDetailViewController.h"

@interface ATEventBookmarkViewController ()
- (void)initATEventBookmarkViewController;
@end


@implementation ATEventBookmarkViewController

- (id)init {
    LOG_CURRENT_METHOD;
    if ((self = [super init])) {
        [self initATEventBookmarkViewController];
    }
    return self;
}

- (void)initATEventBookmarkViewController {
    _editActionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                                          target:self 
                                                                          action:@selector(editAction:)];
    _doneActionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                          target:self 
                                                                          action:@selector(doneAction:)];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_editActionButtonItem release];
    [_doneActionButtonItem release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [super viewWillAppear:animated];
    
    NSMutableArray *eventArray = [ATEventOutlineManager fetchArrayForBookmark];
    
    ATTableData *tableData = [_data objectAtIndex:0];
    if ([tableData.rows count] != [eventArray count]) {
        tableData.rows = eventArray;
        [self.tableView reloadData];
    }
    
    POOL_END;
}

#pragma mark - Overwride methods

- (NSString *)titleString {
    return @"ブックマーク";
}

- (void)setupCellData {
    POOL_START;
    self.data = [NSArray arrayWithObject:[ATTableData tableData]];
    POOL_END;
}

- (void)setupView {
    LOG_CURRENT_METHOD;
    POOL_START;
    self.navigationItem.rightBarButtonItem = _editActionButtonItem;
    POOL_END;
}


- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    ATTableData *tableData = [_data objectAtIndex:indexPath.section];
    ATEventOutline *eventOutline = [[tableData rows] objectAtIndex:indexPath.row];
    [(ATEventOutlineCell *)cell setEventOutline:eventOutline];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    POOL_START;
    ATTableData *tableData = [_data objectAtIndex:indexPath.section];
    ATEventOutline *outline = [[tableData rows] objectAtIndex:indexPath.row];
    if (outline.type == ATEventTypeAtnd) {
        ATAtndEventDetailViewController *ctl = [[[ATAtndEventDetailViewController alloc] 
                                                 initWithEventObject:outline.eventObject] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (outline.type == ATEventTypeFacebook) {
        ATFbEventDetailViewController *ctl = [[[ATFbEventDetailViewController alloc] 
                                               initWithEventObject:outline.eventObject] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    POOL_END;
}


#pragma mark - UITableViewDelegate & DataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	LOG_CURRENT_METHOD;

	if (editingStyle == UITableViewCellEditingStyleDelete) {
        ATTableData *tableData = [_data objectAtIndex:indexPath.section];
        NSMutableArray *rows = [tableData rows];
        if (indexPath.row < rows.count) {
            NSString *identifier = [[rows objectAtIndex:indexPath.row] managedObjectIdentifier];
            [[ATEventForBookmarkManager sharedATEventForBookmarkManager] removeObjectAtIdentifier:identifier];

            [rows removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Public

- (void)editAction:(id)sender {
    LOG_CURRENT_METHOD;
    self.navigationItem.rightBarButtonItem = _doneActionButtonItem;
	[self.tableView setEditing:YES animated:YES];
}

- (void)doneAction:(id)sender {
    LOG_CURRENT_METHOD;
    self.navigationItem.rightBarButtonItem = _editActionButtonItem;
	[self.tableView setEditing:NO animated:YES];
}

@end
