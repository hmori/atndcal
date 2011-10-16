//
//  ATSettingMenuViewController.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATSettingMenuViewController.h"
#import "ATCommon.h"

#import "ATTitleView.h"

#import "ATSettingLoadDaysViewController.h"
#import "ATSettingAutoLoadingViewController.h"

#import "ATEventForDate.h"
#import "ATEventForAttend.h"
#import "ATEventForBookmark.h"
#import "ATKeywordHistory.h"


@interface ATSettingMenuViewController ()
- (void)initATSettingMenuViewController;
- (NSString *)titleString;
- (void)setupTitle;
- (void)setupView;
@end

@implementation ATSettingMenuViewController

#pragma mark - View lifecycle

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATSettingMenuViewController];
    }
    return self;
}

- (void)initATSettingMenuViewController {
    POOL_START;
    
    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    [fbConnecter addObserver:self 
                  forKeyPath:@"countUpdateMeData" 
                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                     context:NULL];

    ATSetting *setting = [ATSetting sharedATSetting];
    ATResource *resource = [ATResource sharedATResource];
    
    _userNameCell = [[ATLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _userNameCell.textLabel.text = [setting objectForItemKey:@"Title" key:kDefaultsSettingAtndNickname];
    _userNameCell.field.placeholder = @"username";
    
    _requestDaysCountCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _requestDaysCountCell.textLabel.text = [setting objectForItemKey:@"Title" key:kDefaultsSettingAtndLoadDaysValue];
    _requestDaysCountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    

    _facebookLoginCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIImageView *loginImageView = 
    [[[UIImageView alloc] initWithImage:[resource imageOfPath:@"FBConnect.bundle/images/LoginNormal.png"] 
                       highlightedImage:[resource imageOfPath:@"FBConnect.bundle/images/LoginPressed.png"]] autorelease];
    loginImageView.center = _facebookLoginCell.contentView.center;
    [_facebookLoginCell.contentView addSubview:loginImageView];
    
    _facebookLogoutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIImageView *logoutImageView = 
    [[[UIImageView alloc] initWithImage:[resource imageOfPath:@"FBConnect.bundle/images/LogoutNormal.png"] 
                       highlightedImage:[resource imageOfPath:@"FBConnect.bundle/images/LogoutPressed.png"]] autorelease];
    logoutImageView.center = _facebookLogoutCell.contentView.center;
    [_facebookLogoutCell.contentView addSubview:logoutImageView];
    
    
    _requestAutoLoadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _requestAutoLoadingCell.textLabel.text = [setting objectForItemKey:@"Title" key:kDefaultsSettingAutoLoadingValue];
    _requestAutoLoadingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _dataResetCell = [[TKButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    _dataResetCell.textLabel.text = @"キャッシュクリア";
    
    POOL_END;
}


- (void)dealloc {
    [[ATCommon facebookConnecter] removeObserver:self forKeyPath:@"countUpdateMeData"];

    [_userNameCell release];
    [_requestDaysCountCell release];
    [_facebookLoginCell release];
    [_facebookLogoutCell release];
    [_requestAutoLoadingCell release];
    [_dataResetCell release];
    [super dealloc];
}

- (void)loadView {
    LOG_CURRENT_METHOD;
    [super loadView];
    
    [self setupTitle];
    [self setupView];
    self.title = [self titleString];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    
    _userNameCell.field.text = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsSettingAtndNickname];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    NSInteger row = 0;
    if (section == 0) {
        row = 2;
    } else if (section == 1) {
        row = 1;
    } else if (section == 2) {
        row = 1;
    } else if (section == 3) {
        row = 1;
    }
	return row;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        title = [[[[ATSetting sharedATSetting] preferenceSpecifiersOfRoot] objectAtIndex:0] objectForKey:@"Title"];
    } else if (section == 1) {
        title = @"Facebook";
    } else if (section == 2) {
        title = @"自動";
    } else if (section == 3) {
        title = @"データ";
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
    
    ATSetting *setting = [ATSetting sharedATSetting];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = _userNameCell;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        cell = _requestDaysCountCell;
        cell.detailTextLabel.text = 
        [setting stringTitleOfValue:[defaults objectForKey:kDefaultsSettingAtndLoadDaysValue] 
                                key:kDefaultsSettingAtndLoadDaysValue];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
        if ([fbConnecter.facebook isSessionValid]) {
            cell = _facebookLogoutCell;
        } else {
            cell = _facebookLoginCell;
        }
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        cell = _requestAutoLoadingCell;
        cell.detailTextLabel.text = 
        [setting stringTitleOfValue:[defaults objectForKey:kDefaultsSettingAutoLoadingValue] 
                                key:kDefaultsSettingAutoLoadingValue];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        cell = _dataResetCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        ATSettingLoadDaysViewController *ctl = [[[ATSettingLoadDaysViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
        if ([fbConnecter.facebook isSessionValid]) {
            ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"Facebook"] autorelease];
            [actionSheet addButtonWithTitle:@"ログアウト" callback:^(ATActionSheet *actionSheet, NSInteger index) {
                [self fbLogoutAction:nil];
            }];
            [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        } else {
            [self fbLoginAction:nil];
        }
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        ATSettingAutoLoadingViewController *ctl = [[[ATSettingAutoLoadingViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        
        ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"保存されたキャッシュデータをクリアします。"] autorelease];
        [actionSheet addDestructiveButtonWithTitle:@"キャッシュクリア" callback:^(ATActionSheet *actionSheet, NSInteger index) {
            [self clearDataAction:nil];
        }];
        [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    POOL_END;
}

#pragma mark - Overwride methods

- (NSString *)titleString {
    return @"設定";
}

- (void)setupTitle {
    POOL_START;
    ATTitleView *titleView = [[[ATTitleView alloc] init] autorelease];
    [titleView setTitle:[self titleString]];
    self.navigationItem.titleView = titleView;
    
    self.title = [self titleString];
    POOL_END;
}

- (void)setupView {
    POOL_START;
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                  target:self 
                                                  action:@selector(doneAction:)] autorelease];
    }
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:
                                               [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)] autorelease]] autorelease];
    
    POOL_END;
}

#pragma mark - Public

- (void)doneAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;

    NSString *nickname = [[_userNameCell.field.text copy] autorelease];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nickname forKey:kDefaultsSettingAtndNickname];
    [defaults synchronize];
    
    [self dismissModalViewControllerAnimated:YES];
    
    POOL_END;
}

- (void)fbLoginAction:(id)sender {
    LOG_CURRENT_METHOD;
    ATFacebookConnecter *fb = [ATCommon facebookConnecter];
    [fb.facebook authorize:fb.facebookPermissions];
}

- (void)fbLogoutAction:(id)sender {
    LOG_CURRENT_METHOD;
    ATFacebookConnecter *fb = [ATCommon facebookConnecter];
    [fb.facebook logout:fb];
}

- (void)clearDataAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [[ATEventForDateManager sharedATEventForDateManager] truncate];
    [[ATEventForAttendManager sharedATEventForAttendManager] truncate];
    [[ATEventForBookmarkManager sharedATEventForBookmarkManager] truncate];
    [[ATKeywordHistoryManager sharedATKeywordHistoryManager] truncate];
    
    [[[ATCommon appDelegate] calenderCtl] resetData];
    
    NSString *message = @"クリアしました";
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    
    POOL_END;
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    LOG_CURRENT_METHOD;
    if ([keyPath isEqualToString:@"countUpdateMeData"]) {
        [self.tableView reloadData];
    }
}

@end
