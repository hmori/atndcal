//
//  ATTextAnalysisViewController.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/09/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATTextAnalysisViewController.h"
#import "ATCommon.h"

#import "ATKeyphraseParser.h"
#import "ATWebViewController.h"

@interface ATTextAnalysisViewController ()
@property (nonatomic, retain) NSMutableArray *keyphraseArray;
@property (nonatomic, retain) NSMutableArray *accessoryArray;

- (void)initATTextAnalysisViewController;
- (void)refreshCellData;
- (void)requestAnalysisService:(NSDictionary *)param;

- (void)successAnalysisRequest:(NSDictionary *)userInfo;
- (void)errorAnalysisRequest:(NSDictionary *)userInfo;
@end



@implementation ATTextAnalysisViewController
@synthesize sentence = _sentence;
@synthesize keyphraseArray = _keyphraseArray;
@synthesize accessoryArray = _accessoryArray;

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        [self initATTextAnalysisViewController];
    }
    return self;
}

- (void)initATTextAnalysisViewController {
    POOL_START;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notificationAnalysisRequest:) 
                                                 name:ATNotificationNameAnalysisRequest 
                                               object:nil];
    
    self.keyphraseArray = [NSMutableArray arrayWithCapacity:0];
    self.accessoryArray = [NSMutableArray arrayWithCapacity:0];
    POOL_END;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_sentence release];
    [_keyphraseArray release];
    [_accessoryArray release];
    [super dealloc];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    [self reloadAction:nil];
}

#pragma mark - Overwride ATTableViewController

- (NSString *)titleString {
    return @"キーワード抽出";
}

- (void)setupView {
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
    
    POOL_END;
}

- (void)setupCellData {
    LOG_CURRENT_METHOD;
}

- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    [super setupCellForRowAtIndexPath:indexPath cell:cell];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    POOL_START;
    NSString *urlString = [NSString stringSearchGoogleUrlWithKeyword:[_keyphraseArray objectAtIndex:indexPath.row]];
    [self openWebView:nil url:urlString];
    POOL_END;
}

#pragma mark - Public

- (void)reloadAction:(id)sender {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    static NSString *atndcalYolpKey = kAtndcalYolpKey;
    static NSString *kAppid = @"appid";
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:[_sentence stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"sentence"];
    [param setObject:atndcalYolpKey forKey:kAppid];
    [self requestAnalysisService:param];
    POOL_END;
}

- (void)closeAction:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)openWebView:(id)sender url:(NSString *)urlString {
    LOG_CURRENT_METHOD;
    POOL_START;
    ATWebViewController *ctl = [[[ATWebViewController alloc] initWithUrlString:urlString] autorelease];
    [self.navigationController pushViewController:ctl animated:YES];
    POOL_END;
}


#pragma mark - Private 

- (void)refreshCellData {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
    d = [ATTableData tableData];
    d.rows = _keyphraseArray;
    d.accessorys = _accessoryArray;
    d.footer = @"Webサービス by Yahoo! JAPAN";
	[tmp addObject:d];
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];

    [self.tableView reloadData];
    
    POOL_END;
}

- (void)requestAnalysisService:(NSDictionary *)param {
    LOG_CURRENT_METHOD;
    POOL_START;
    static NSString *yolpKeyphraseUrl = @"http://jlp.yahooapis.jp/KeyphraseService/V1/extract";
    
    NSString *postString = [NSString stringForURLParam:param method:@"POST"];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:yolpKeyphraseUrl]
                                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                             timeoutInterval:30.0f] autorelease];
	[request setHTTPMethod:@"POST"];
    [request setPostData:postData];
    ATRequestOperation *operation = [[[ATRequestOperation alloc] initWithDelegate:self 
                                                                 notificationName:ATNotificationNameAnalysisRequest 
                                                                          request:request] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [[ATOperationManager sharedATOperationManager] addOperation:operation];
    
    POOL_END;
}

#pragma mark - Yolp Callback

- (void)notificationAnalysisRequest:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:kATRequestUserInfoError];
    NSNumber *statusCode = [userInfo objectForKey:kATRequestUserInfoStatusCode];
    if (!error && statusCode && [statusCode integerValue] == 200) {
        [self successAnalysisRequest:userInfo];
    } else {
        [self errorAnalysisRequest:userInfo];
    }
}

- (void)successAnalysisRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;

#if DEBUG
    NSString *jsonString = [[[NSString alloc] initWithData:[userInfo objectForKey:kATRequestUserInfoReceivedData] 
                                                  encoding:NSUTF8StringEncoding] autorelease];
    LOG(@"jsonString=%@", jsonString);
#endif    

    ATKeyphraseParser *parser = [[[ATKeyphraseParser alloc] init] autorelease];
    [parser parse:[userInfo objectForKey:kATRequestUserInfoReceivedData]];
    NSArray *results =  parser.results;
    for (ATKeyphraseResult *result in results) {
        POOL_START;
        [_keyphraseArray addObject:result.keyphrase];
        [_accessoryArray addObject:[NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator]];
        POOL_END;
    }
    [self refreshCellData];
    
    POOL_END;
}

- (void)errorAnalysisRequest:(NSDictionary *)userInfo {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSString *message = [NSString stringWithFormat:@"Server Error\nStatus : %@",  [userInfo objectForKey:kATRequestUserInfoStatusCode]];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:message];
    [[ATOperationManager sharedATOperationManager] cancelAllOperationOfName:ATNotificationNameAnalysisRequest];
    
    [_keyphraseArray addObject:_sentence];
    [self refreshCellData];
    POOL_END;
}

@end
