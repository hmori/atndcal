//
//  ATResource.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATResource.h"
#import "ObjectSingleton.h"
#import "ATCommon.h"

@interface ATResource () 
@property (nonatomic, retain) NSMutableDictionary *resouceDictionary;
- (NSString *)fullBundlePath:(NSString *)bundlePath;
- (NSString *)convertImagePathForScale:(NSString *)path;
@end

@implementation ATResource
@synthesize resouceDictionary = _resouceDictionary;

OBJECT_SINGLETON_TEMPLATE(ATResource, sharedATResource)

- (void)dealloc {
    [_resouceDictionary release];
    [super dealloc];
}

#pragma mark - getter

- (NSMutableDictionary *)resourceDictionary {
    if (!_resouceDictionary) {
        POOL_START;
        self.resouceDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        POOL_END;
    }
    return _resouceDictionary;
}

#pragma mark - Private 

- (NSString *)fullBundlePath:(NSString *)bundlePath {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
}

- (NSString *)convertImagePathForScale:(NSString *)path {
    
    static NSString *pngExtString = @".png";
    static NSString *png2xExtString = @"@2x.png";
    static NSString *pathFormat2xString = @"%@@2x";
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale == 2.0f) {
        if ([path hasSuffix:pngExtString]) {
            path = [path stringByReplacingOccurrencesOfString:pngExtString 
                                                   withString:png2xExtString 
                                                      options:NSLiteralSearch 
                                                        range:NSMakeRange(path.length-4, 4)];
        } else {
            path = [NSString stringWithFormat:pathFormat2xString, path];
        }
    }
    return path;
}

#pragma mark - Public

- (UIImage *)imageOfPath:(NSString *)path {
    UIImage *image = [self.resouceDictionary objectForKey:path];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:[self convertImagePathForScale:[self fullBundlePath:path]]];
        [self.resouceDictionary setObject:image forKey:path];
    }
    return image;
}


@end
