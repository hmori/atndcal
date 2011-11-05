//
//  ATSettingEvernoteViewController.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATSettingEvernoteViewController.h"
#import "ATCommon.h"

@interface ATSettingEvernoteViewController ()
@property (nonatomic, retain) ATWaitingView *waitingView;
- (void)initATSettingEvernoteViewController;
- (NSString *)titleString;
- (void)setupTitle;
- (void)setupView;
@end


@implementation ATSettingEvernoteViewController
@synthesize waitingView = _waitingView;

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATSettingEvernoteViewController];
    }
    return self;
}

- (void)initATSettingEvernoteViewController {
    POOL_START;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _usernameCell = [[ATLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _usernameCell.textLabel.text = @"ユーザー名";
    _usernameCell.field.placeholder = @"username";
    _usernameCell.field.text = [defaults objectForKey:kDefaultsEvernoteUsername];


    _passwordCell = [[ATLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _passwordCell.textLabel.text = @"パスワード";
    _passwordCell.field.placeholder = @"password";
    _passwordCell.field.secureTextEntry = YES;
    _passwordCell.field.text = [defaults objectForKey:kDefaultsEvernotePassword];
    
    POOL_END;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_usernameCell release];
    [_passwordCell release];
    [_waitingView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    LOG_CURRENT_METHOD;
    [super loadView];
    
    [self setupTitle];
    [self setupView];
    self.title = [self titleString];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/


#pragma mark - UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
	UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        cell = _usernameCell;
    } else {
        cell = _passwordCell;
    }
    return cell;
}

#pragma mark - Overwride methods

- (NSString *)titleString {
    return @"Evernote設定";
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
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"閉じる" 
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:self 
                                                                                 action:@selector(closeAction:)] autorelease];
    }
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                               target:self 
                                               action:@selector(doneAction:)] autorelease];
    
    POOL_END;
}

#pragma mark - Public

- (void)closeAction:(id)sender {
    LOG_CURRENT_METHOD;
    id parent = [((UINavigationController *)self.presentingViewController).viewControllers lastObject];
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if ([parent respondsToSelector:@selector(clipEvernote:)]) {
            [parent performSelector:@selector(clipEvernote:)];
        }
    }];
}

- (void)doneAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    [_usernameCell.field resignFirstResponder];
    [_passwordCell.field resignFirstResponder];
    
    if (_usernameCell.field.text && _usernameCell.field.text.length > 0) {
        
        self.waitingView = [[[ATWaitingView alloc] init] autorelease];
        [_waitingView setTitle:@"ログイン中"];
        [self.view addSubview:_waitingView];
        
        NSInvocationOperation *invOperation = [[[NSInvocationOperation alloc] 
                                                initWithTarget:self 
                                                selector:@selector(authorizeEvernote:) 
                                                object:nil] autorelease];
        invOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
        [[ATOperationManager sharedATOperationManager] addOperation:invOperation];
        
    } else {
        NSString *message = @"ユーザー名・パスワードを入力してください.";
        [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    }
    
    POOL_END;
}



#pragma mark - Private 

- (void)authorizeEvernote:(id)sender {
    LOG_CURRENT_METHOD;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_usernameCell.field.text forKey:kDefaultsEvernoteUsername];
    [defaults setObject:_passwordCell.field.text forKey:kDefaultsEvernotePassword];
    
    ATEvernoteConnecter *connecter = [ATEvernoteConnecter sharedATEvernoteConnecter];
    if (![connecter authorize]) {
        [defaults removeObjectForKey:kDefaultsEvernoteUsername];
        [defaults removeObjectForKey:kDefaultsEvernotePassword];
    }
    [defaults synchronize];
    
    [self performSelectorOnMainThread:@selector(removeWaitingView) 
                           withObject:nil 
                        waitUntilDone:YES];
}

- (void)removeWaitingView {
    LOG_CURRENT_METHOD;
    [_waitingView removeFromSuperview];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEvernoteUsername];
    if (username) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"ログインしました."];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
