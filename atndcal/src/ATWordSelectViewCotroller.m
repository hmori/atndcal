#import "ATWordSelectViewCotroller.h"
#import "ATKeywordHistory.h"

@implementation ATWordSelectViewCotroller

@synthesize delegate = _delegate;

- (NSString *)titleString {
    return @"検索キーワード選択";
}

- (void)setupView {
    POOL_START;
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"閉じる" 
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:self 
                                                                                 action:@selector(closeAction:)] autorelease];
    }
    POOL_END;
}

- (void)setupCellData {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    ATTableData *d;
	NSMutableArray *tmp = [NSMutableArray array];
    
    d = [ATTableData tableData];
    d.rows = [[ATKeywordHistoryManager sharedATKeywordHistoryManager] fetchReversedKeywords];
    d.title = @"キーワード履歴";
	[tmp addObject:d];

    d = [ATTableData tableData];
    d.rows = [NSArray arrayWithObjects:
              @"東京 or tokyo or 関東 or kanto", 
              @"大阪 or osaka or 関西 or kansai",
              @"名古屋 or nagoya or 中部 or chubu",
              @"福岡 or fukuoka or 九州 or kyushu",
              @"札幌 or sapporo or 北海道 or hokkaido",
              @"仙台 or sendai or 東北 or tohoku",
              @"新潟 or niigata or 北陸 or hokuriku",
              @"岡山 or okayama or 中国 or chugoku",
              @"広島 or hiroshima or 中国 or chugoku",
              nil];
    d.title = @"地域";
	[tmp addObject:d];
	
	self.data = [[[NSArray alloc] initWithArray:tmp] autorelease];

    POOL_END;
}

- (UITableViewCell *)setupCellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell {
    [super setupCellForRowAtIndexPath:indexPath cell:cell];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    return cell;
}

- (void)actionDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ATTableData *tableData = [_data objectAtIndex:indexPath.section];
    NSString *text = [[tableData rows] objectAtIndex:indexPath.row];
    
    if (_delegate) {
        [_delegate performSelector:@selector(wordSelect:) withObject:text];
    }
    [self closeAction:nil];
}

#pragma mark - Public

- (void)closeAction:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissModalViewControllerAnimated:YES];
}


@end

