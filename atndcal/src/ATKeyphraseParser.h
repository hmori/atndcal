#import <Foundation/Foundation.h>

#import "ATKeyphraseResult.h"

@interface ATKeyphraseParser : NSObject <NSXMLParserDelegate> {
    NSMutableArray *_results;
    NSMutableString *_buffer;
  
    ATKeyphraseResult *_currentResult; //week reference

    BOOL _isResultSet;
    BOOL _isResult;
}
@property (nonatomic, retain) NSMutableArray *results;

- (void)parse:(NSData *)data;

@end
