//
//  ATEventListViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventListViewController.h"
#import "ATCommon.h"

#import "ATTitleView.h"
#import "ATEventOutlineCell.h"
#import "ATEventDetailViewController.h"

@interface ATEventListViewController ()
- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell;
@end


@implementation ATEventListViewController

#pragma mark - UITableViewDelegate && DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    ATEventOutlineCell *cell = (ATEventOutlineCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ATEventOutlineCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:CellIdentifier] autorelease];
    }
    return [self setupCellForRowAtIndexPath:indexPath cell:cell];
}

#pragma mark - Overwride methods

- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    return cell;
}

@end