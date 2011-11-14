#import "ATSettingMenuViewController.h"
#import "ATCommon.h"

#import "ATSettingLoadDaysViewController.h"
#import "ATSettingAutoLoadingViewController.h"
#import "ATSettingEvernoteViewController.h"

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
    
    _usernameCell = [[ATLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _usernameCell.textLabel.text = [setting objectForItemKey:@"Title" key:kDefaultsSettingAtndNickname];
    _usernameCell.field.placeholder = @"username";
    
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

    _evernoteCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _evernoteCell.textLabel.text = @"Evernote";
    _evernoteCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _requestAutoLoadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _requestAutoLoadingCell.textLabel.text = [setting objectForItemKey:@"Title" key:kDefaultsSettingAutoLoadingValue];
    _requestAutoLoadingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _dataResetCell = [[TKButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    _dataResetCell.textLabel.text = @"キャッシュクリア";

    
    _sectionItems = [[NSMutableArray alloc] initWithCapacity:0];
    [_sectionItems addObject:[NSNumber numberWithInt:ATSettingMenuSectionAtnd]];
    [_sectionItems addObject:[NSNumber numberWithInt:ATSettingMenuSectionFacebook]];
    [_sectionItems addObject:[NSNumber numberWithInt:ATSettingMenuSectionEvernote]];
    [_sectionItems addObject:[NSNumber numberWithInt:ATSettingMenuSectionAuto]];
    [_sectionItems addObject:[NSNumber numberWithInt:ATSettingMenuSectionReset]];
    POOL_END;
}


- (void)dealloc {
    [[ATCommon facebookConnecter] removeObserver:self forKeyPath:@"countUpdateMeData"];

    [_sectionItems release];
    [_usernameCell release];
    [_requestDaysCountCell release];
    [_facebookLoginCell release];
    [_facebookLogoutCell release];
    [_evernoteCell release];
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
    
    _usernameCell.field.text = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsSettingAtndNickname];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    return _sectionItems.count;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    NSInteger row = 0;
    
    ATSettingMenuSection sectionItem = [[_sectionItems objectAtIndex:section] intValue];
    if (sectionItem == ATSettingMenuSectionAtnd) {
        row = 2;
    } else if (sectionItem == ATSettingMenuSectionFacebook) {
        row = 1;
    } else if (sectionItem == ATSettingMenuSectionEvernote) {
        row = 1;
    } else if (sectionItem == ATSettingMenuSectionAuto) {
        row = 1;
    } else if (sectionItem == ATSettingMenuSectionReset) {
        row = 1;
    }
	return row;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    ATSettingMenuSection sectionItem = [[_sectionItems objectAtIndex:section] intValue];
    if (sectionItem == ATSettingMenuSectionAtnd) {
        title = [[[[ATSetting sharedATSetting] preferenceSpecifiersOfRoot] objectAtIndex:0] objectForKey:@"Title"];
    } else if (sectionItem == ATSettingMenuSectionFacebook) {
        title = @"Facebook";
    } else if (sectionItem == ATSettingMenuSectionEvernote) {
        title = @"Evernote";
    } else if (sectionItem == ATSettingMenuSectionAuto) {
        title = @"自動";
    } else if (sectionItem == ATSettingMenuSectionReset) {
        title = @"データ";
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
	UITableViewCell *cell = nil;
    
    ATSetting *setting = [ATSetting sharedATSetting];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ATSettingMenuSection sectionItem = [[_sectionItems objectAtIndex:indexPath.section] intValue];
    if (sectionItem == ATSettingMenuSectionAtnd) {
        if (indexPath.row == 0) {
            cell = _usernameCell;
        } else if (indexPath.row == 1) {
            cell = _requestDaysCountCell;
            cell.detailTextLabel.text = 
            [setting stringTitleOfValue:[defaults objectForKey:kDefaultsSettingAtndLoadDaysValue] 
                                    key:kDefaultsSettingAtndLoadDaysValue];
        }
    } else if (sectionItem == ATSettingMenuSectionFacebook) {
        ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
        if ([fbConnecter.facebook isSessionValid]) {
            cell = _facebookLogoutCell;
        } else {
            cell = _facebookLoginCell;
        }
    } else if (sectionItem == ATSettingMenuSectionEvernote) {
        cell = _evernoteCell;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        cell.detailTextLabel.text = [defaults objectForKey:kDefaultsEvernoteUsername];
    } else if (sectionItem == ATSettingMenuSectionAuto) {
        cell = _requestAutoLoadingCell;
        cell.detailTextLabel.text = 
        [setting stringTitleOfValue:[defaults objectForKey:kDefaultsSettingAutoLoadingValue] 
                                key:kDefaultsSettingAutoLoadingValue];
    } else if (sectionItem == ATSettingMenuSectionReset) {
        cell = _dataResetCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ATSettingMenuSection sectionItem = [[_sectionItems objectAtIndex:indexPath.section] intValue];
    if (sectionItem == ATSettingMenuSectionAtnd) {
        if (indexPath.row == 1) {
            ATSettingLoadDaysViewController *ctl = [[[ATSettingLoadDaysViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            [self.navigationController pushViewController:ctl animated:YES];
        }
    } else if (sectionItem == ATSettingMenuSectionFacebook) {
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
    } else if (sectionItem == ATSettingMenuSectionEvernote) {
        ATSettingEvernoteViewController *ctl = [[[ATSettingEvernoteViewController alloc] init] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (sectionItem == ATSettingMenuSectionAuto) {
        ATSettingAutoLoadingViewController *ctl = [[[ATSettingAutoLoadingViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (sectionItem == ATSettingMenuSectionReset) {
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

    NSString *nickname = [[_usernameCell.field.text copy] autorelease];
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
