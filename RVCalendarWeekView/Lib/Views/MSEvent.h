//
//  AKEvent.h
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DateTools/DTTimePeriod.h>

@interface MSEvent : DTTimePeriod

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *location;
@property (nonatomic, strong) NSString  *restTime;
@property (nonatomic, strong) NSString  *eventId;
@property (assign, nonatomic) NSInteger  classTime;


+(instancetype)make:(NSDate*)start title:(NSString*)title subtitle:(NSString*)subtitle;
+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle eventId:(NSString*)eventId;
+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle restTime:(NSString*)restTime eventId:(NSString*)eventId classTime:(NSInteger)classTime;

+(instancetype)make:(NSDate*)start duration:(int)minutes title:(NSString*)title subtitle:(NSString*)subtitle;

- (NSDate *)day;

@end
