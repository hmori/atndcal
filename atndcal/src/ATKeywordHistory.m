#import "ATKeywordHistory.h"
#import "ObjectSingleton.h"

@implementation ATKeywordHistoryManager

OBJECT_SINGLETON_TEMPLATE(ATKeywordHistoryManager, sharedATKeywordHistoryManager)

static NSString *KeywordHistory = @"KeywordHistory";

#define historyCapacity 6

- (NSString *)entityName {
    return KeywordHistory;
}

- (NSError *)saveKeyword:(NSString *)keyword {
    NSArray *keywordResult = [self select:KeywordHistory where:[NSString stringWithFormat:@"keyword='%@'", keyword]];
    for ( ATKeywordHistory *history in keywordResult ) {
        [self delete:history];
    }
    
    NSArray *allResult = [self select:KeywordHistory where:nil];
    if ( allResult.count >= historyCapacity ) {
        [self delete:[allResult objectAtIndex:0]];
    }
    
    ATKeywordHistory *history = [(ATKeywordHistory *)[self new:KeywordHistory] autorelease];
    history.keyword = keyword;
    history.createAt = [NSDate date];
    
    return [self save];
}

- (NSMutableArray *)fetchReversedKeywords {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSArray *result = [self select:KeywordHistory where:nil sortKey:@"createAt" ascending:NO];
    for (ATKeywordHistory *keywordHistory in result) {
        [array addObject:keywordHistory.keyword];
    }
    return array;
}

@end


@implementation ATKeywordHistory
@dynamic identifier;
@dynamic keyword;
@dynamic createAt;
@end
