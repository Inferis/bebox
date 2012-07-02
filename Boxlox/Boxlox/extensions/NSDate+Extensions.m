//
//  NSDate+Extensions.m
//


#import "NSDate+Extensions.h"
#import "NSDate+Formatting.h"
#import "NSDate+JSON.h"

@implementation NSDate (Extensions)

static NSString* DayFormat = @"yyyyMMdd";

#pragma mark - Instance methods

- (NSDate*)nextDay {
    return [[self dayLater] startOfDay];
}

- (NSDate*)previousDay {
    return [[self dayEarlier] startOfDay];
}

- (NSDate*)dayLater {
    return [self dateByAddingTimeInterval:24*60*60];
}

- (NSDate*)dayEarlier {
    return [self dateByAddingTimeInterval:-24*60*60];
}

- (NSDate*)startOfDay {
    return [NSDate dateFromString:[self formatAs:DayFormat] withFormat:DayFormat];    
}

- (NSDate*)endOfDay {
    return [[NSDate dateFromString:[self formatAs:DayFormat] withFormat:DayFormat] dateByAddingTimeInterval:24*60*60-1];    
}

#pragma mark - Class methods

+ (NSDate*)today {
    return [[NSDate date] startOfDay];
}

+ (NSDate*)tomorrow {
    return [[NSDate date] nextDay];
}

+ (NSDate*)yesterday {
    return [[NSDate date] previousDay];
}

- (BOOL)isLaterThan:(NSDate*)other {
    return [self compare:other] == NSOrderedDescending;
}

- (BOOL)isEarlierThan:(NSDate*)other {
    return [self compare:other] == NSOrderedAscending;
}

- (BOOL)isOnSameDayAs:(NSDate*)other {
    return [[self startOfDay] compare:[other startOfDay]] == NSOrderedSame;
}

- (int)dayOfWeek {
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSWeekdayCalendarUnit fromDate:self];
    return [comps weekday];
}


@end
