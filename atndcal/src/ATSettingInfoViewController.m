//
//  ATSettingInfoViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATSettingInfoViewController.h"
#import "ATCommon.h"

#import "ATLocalWebViewController.h"
#import "ATMailComposer.h"

@interface ATSettingInfoViewController ()
@property (nonatomic, retain) ATMailComposer *mailComposer;
- (void)openContactMail;
@end


@implementation ATSettingInfoViewController
@synthesize mailComposer = _mailComposer;


- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    }
    return self;
}

- (void)dealloc {
    [_mailComposer release];
    [super dealloc];
}

#pragma mark - ATTableViewController Overwride

- (NSString *)titleString {
    return @"情報";
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
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
	
    d = [ATTableData tableData];
    d.title = @"アプリケーション";
    d.rows = [NSArray arrayWithObjects:@"名前",@"バージョン",@"著作権",@"コンタクト",nil];
    d.detailRows = [NSArray arrayWithObjects:
                    [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"],
                    [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"],
                    kAtndcalInfoProgrammerName,
                    [NSNull null], nil];
    d.accessorys = [NSArray arrayWithObjects:
                    [NSNull null],
                    [NSNull null],
                    [NSNull null],
                    [NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator],nil];
	[tmp addObject:d];
	
    d = [ATTableData tableData];
    d.title = @"クレジット";
    d.rows = [NSArray arrayWithObjects:@"プログラミング",@"アイコンデザイン",@"ライセンス",nil];
    d.detailRows = [NSArray arrayWithObjects:
                    kAtndcalInfoProgrammerName,
                    kAtndcalInfoDesinerName,
                    [NSNull null], nil];
    d.accessorys = [NSArray arrayWithObjects:
                    [NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator],
                    [NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator],
                    [NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator],nil];
	[tmp addObject:d];
	
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    POOL_END;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    return [self setupCellForRowAtIndexPath:indexPath cell:cell];
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    POOL_START;
    if (indexPath.section == 0 && indexPath.row == 3) {
        [self contactAction:nil];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        ATLocalWebViewController *ctl = [[[ATLocalWebViewController alloc] 
                                          initWithFilename:@"OwnerInfo.html"
                                          title:@"プログラミング"] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        ATLocalWebViewController *ctl = [[[ATLocalWebViewController alloc] 
                                          initWithFilename:@"CollaboratorInfo.html"
                                          title:@"アイコンデザイン"] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        ATLocalWebViewController *ctl = [[[ATLocalWebViewController alloc] 
                                          initWithFilename:@"License.html"
                                          title:@"ライセンス"] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    POOL_END;
}


#pragma mark - Public

- (void)contactAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"バグ報告、要望等いただければ幸いです"] autorelease];
    [actionSheet addButtonWithTitle:@"メールを開く" callback:^(ATActionSheet *actionSheet, NSInteger index) {
        [self openContactMail];
    }];
    [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
    [actionSheet showInView:self.view];
    
    POOL_END;
}

#pragma mark - Private

- (void)openContactMail {
    POOL_START;
    
    self.mailComposer = [[[ATMailComposer alloc] init] autorelease];
    [_mailComposer setToRecipient:kAtndcalInfoContactEmail];
    NSString *subject = [NSString stringWithFormat:@"[コンタクト]%@ ver%@ ", 
                         [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"], 
                         [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]];
    [_mailComposer setSubject:subject];
    
    [_mailComposer openMailOnViewController:self];
    
    POOL_END;
}

@end
