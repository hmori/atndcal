//
//  ATKeyphraseResult.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/09/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATKeyphraseResult : NSObject {
    NSString *_keyphrase;
    NSString *_score;
}
@property (nonatomic, copy) NSString *keyphrase;
@property (nonatomic, copy) NSString *score;

@end
