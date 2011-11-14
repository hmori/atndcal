#import <Foundation/Foundation.h>


@interface ATKeyphraseResult : NSObject {
    NSString *_keyphrase;
    NSString *_score;
}
@property (nonatomic, copy) NSString *keyphrase;
@property (nonatomic, copy) NSString *score;

@end
