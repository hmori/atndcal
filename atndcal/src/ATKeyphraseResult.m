#import "ATKeyphraseResult.h"


@implementation ATKeyphraseResult
@synthesize keyphrase = _keyphrase;
@synthesize score = _score;


- (void)dealloc {
    [_keyphrase release];
    [_score release];
    [super dealloc];
}

@end
