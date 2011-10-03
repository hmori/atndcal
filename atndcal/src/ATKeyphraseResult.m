//
//  ATKeyphraseResult.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/09/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
