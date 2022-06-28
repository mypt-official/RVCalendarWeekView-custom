//
//  NSObject+Util.h
//  AAInfographics
//
//  Created by 김민아 on 2020/01/16.
//

#import <Foundation/Foundation.h>

@interface Util: NSObject

+ (instancetype)sharedInstance;

@property (assign, nonatomic) BOOL nowLoading;
@property(assign, nonatomic) float pageXValue;
@property(assign, nonatomic) BOOL scrollDisable;

@end


