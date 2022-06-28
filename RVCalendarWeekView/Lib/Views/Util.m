//
//  NSObject+Util.m
//  AAInfographics
//
//  Created by 김민아 on 2020/01/16.
//

#import "Util.h"

@implementation Util

+ (instancetype)sharedInstance
{
    static Util *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Util alloc] init];
        

    });
    
    return _sharedInstance;
}



@end
