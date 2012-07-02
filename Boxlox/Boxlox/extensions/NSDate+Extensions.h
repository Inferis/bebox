//
//  NSDate+Extensions.h
//

#import <Foundation/Foundation.h>


@interface NSDate (Extensions)

- (NSDate*)nextDay;
- (NSDate*)previousDay;
- (NSDate*)dayLater;
- (NSDate*)dayEarlier;
- (NSDate*)startOfDay;
- (NSDate*)endOfDay;

+ (NSDate*)today;
+ (NSDate*)tomorrow;
+ (NSDate*)yesterday;

- (BOOL)isLaterThan:(NSDate*)other;
- (BOOL)isEarlierThan:(NSDate*)other;
- (BOOL)isOnSameDayAs:(NSDate*)other;

- (int)dayOfWeek;

@end
