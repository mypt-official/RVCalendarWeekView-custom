//
//  AKEvent.m
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import "MSEvent.h"
#import "NSDate+Easy.h"

@implementation MSEvent

+(instancetype)make:(NSDate*)start title:(NSString*)title subtitle:(NSString*)subtitle{
    return [self.class make:start duration:60 title:title subtitle:subtitle];
}

+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle eventId:(NSString*)eventId{
    MSEvent* event = [self.class new];
    event.StartDate = start;
    event.EndDate   = end;
    event.title     = title;
    event.location  = subtitle;
    event.eventId = eventId;

    return event;
}

+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle restTime:(NSString*)restTime eventId:(NSString*)eventId classTime:(NSInteger)classTime {
    MSEvent* event = [self.class new];
    event.StartDate = start;
    event.EndDate   = end;
    event.title     = title;
    event.location  = subtitle;
    event.eventId = eventId;
    event.restTime = restTime;
    event.classTime = classTime;
    return event;
}

+(instancetype)make:(NSDate*)start duration:(int)minutes title:(NSString*)title subtitle:(NSString*)subtitle{
    MSEvent* event  = [self.class new];
    event.StartDate = start;
    event.EndDate   = [start addMinutes:minutes];
    event.title     = title;
    event.location  = subtitle;
    return event;
}

- (NSDate *)day{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    return [calendar startOfDayForDate:self.StartDate];
}

- (BOOL)isInDay:(NSDate *)date {
    return [self containsDate:[date setTime:[self.EndDate format:@"HH:mm:ss"]] interval:DTTimePeriodIntervalClosed];
}

@end
