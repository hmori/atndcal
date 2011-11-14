#import "ATMenuViewController.h"
#import "ATCommon.h"

#import "ATEventAttendViewController.h"
#import "ATEventBookmarkViewController.h"
#import "ATSettingMenuViewController.h"

#import "ATSettingInfoViewController.h"


@interface ATMenuViewController ()
- (void)initATMenuViewController;
@end


@implementation ATMenuViewController

#pragma mark - Overwride methods

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATMenuViewController];
    }
    return self;
}

- (void)initATMenuViewController {
    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    [fbConnecter addObserver:self 
                  forKeyPath:@"countUpdateMeData" 
                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                     context:NULL];
}

- (void)dealloc {
    [[ATCommon facebookConnecter] removeObserver:self forKeyPath:@"countUpdateMeData"];
    [super dealloc];
}

- (NSString *)titleString {
    return @"メニュー";
}

- (void)setupCellData {
    LOG_CURRENT_METHOD;
    POOL_START;

    ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
    NSDictionary *dictionary = [fbConnecter dictionaryForMe];
    
    NSString *facebookName = nil;
    NSString *facebookImage = nil;
    if (dictionary) {
        NSString *name = [dictionary objectForKey:@"name"];
        if (name) {
            facebookName = name;
        }
        NSString *id_ = [dictionary objectForKey:@"id"];
        if (id_) {
            facebookImage = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", id_];
        }
    } else {
        facebookName = @"";
    }
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
	
    d = [ATTableData tableData];
    d.title = @"ブックマーク";
    d.rows = [NSArray arrayWithObjects:@"登録したイベント",nil];
    d.pushControllers = [NSArray arrayWithObjects:ATEventBookmarkViewController.class,nil];
	[tmp addObject:d];

    d = [ATTableData tableData];
    d.title = @"ATND";
    d.rows = [NSArray arrayWithObjects:@"参加イベント",nil];
    d.pushControllers = [NSArray arrayWithObjects:ATEventAttendViewController.class,nil];
	[tmp addObject:d];

    d = [ATTableData tableData];
    d.title = @"Facebook";
    d.rows = [NSArray arrayWithObjects:facebookName,nil];
    if (facebookImage) {
        d.imageUrls = [NSArray arrayWithObjects:facebookImage,nil];
    }
	[tmp addObject:d];

    d = [ATTableData tableData];
    d.rows = [NSArray arrayWithObjects:@"アプリケーションについて",nil];
    d.pushControllers = [NSArray arrayWithObjects:ATSettingInfoViewController.class, nil];
    d.title = @"情報";
	[tmp addObject:d];
	
    
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];
    
    POOL_END;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = nil;
    if (indexPath.section == 2 && indexPath.row == 0) {
        static NSString *FacebookCell = @"FacebookCell";
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:FacebookCell] autorelease];
        
        if ([[[[_data objectAtIndex:indexPath.section] rows] objectAtIndex:0] length] == 0) {
            UIImage *image = [[ATResource sharedATResource] imageOfPath:@"FBConnect.bundle/images/LoginNormal.png"];
            UIImage *highlightedImage = [[ATResource sharedATResource] imageOfPath:@"FBConnect.bundle/images/LoginPressed.png"];
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:image highlightedImage:highlightedImage] autorelease];
            imageView.center = cell.contentView.center;
            
            [cell.contentView addSubview:imageView];
        }
        cell = [self setupCellForRowAtIndexPath:indexPath cell:cell];
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    POOL_START;
    [super actionDidSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
        if ([fbConnecter.facebook isSessionValid]) {
            ATActionSheet *actionSheet = [[[ATActionSheet alloc] initWithTitle:@"Facebook"] autorelease];
            [actionSheet addButtonWithTitle:@"再ログイン" callback:^(ATActionSheet *actionSheet, NSInteger index) {
                [self fbLoginAction:nil];
            }];
            [actionSheet addButtonWithTitle:@"ログアウト" callback:^(ATActionSheet *actionSheet, NSInteger index) {
                [self fbLogoutAction:nil];
            }];
            [actionSheet addCancelButtonWithTitle:@"閉じる" callback:nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        } else {
            [self fbLoginAction:nil];
        }
    }
    /*
     //https://graph.facebook.com/search?q=conference&type=event
     
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
     [params setObject:@"event" forKey:@"type"];
     [params setObject:@"sendai" forKey:@"q"];
     
     ATFacebookConnecter *fbConnecter = [ATCommon facebookConnecter];
     [[fbConnecter facebook] requestWithGraphPath:@"search" 
     andParams:params 
     andDelegate:fbConnecter];
     */
    
    POOL_END;
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
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"設定" 
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(settingAction:)] autorelease];
   
    POOL_END;
}

#pragma mark - Public

- (void)closeAction:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)settingAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATSettingMenuViewController *ctl = [[[ATSettingMenuViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
    [self presentModalViewController:nav animated:YES];
    
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


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    LOG_CURRENT_METHOD;
    if ([keyPath isEqualToString:@"countUpdateMeData"]) {
        [self setupCellData];
        [self.tableView reloadData];
    }
}

@end
