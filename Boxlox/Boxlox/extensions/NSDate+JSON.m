//
//  NSDate+JSON.m
//  TouchPoint
//
//  10/06/11.
//  Copyright 2011. All rights reserved.
//

#import "NSDate+JSON.h"

@implementation NSDate (JSON)

// Converts a Rails-formatted timestamp string to an NSDate
//
//      [NSDate dateWithISO8601String:@"2011-06-08T15:50:13Z"];
//
+ (NSDate *)dateWithISO8601String:(NSString *)dateString
{
    if (!dateString) return nil;
    if ([dateString hasSuffix:@"Z"]) {
        dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"-0000"];
    }
    return [self dateFromString:dateString withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}


// Converts a formatted timestamp string to an NSDate
//
//      [NSDate dateFromString:@"2011-06-08T15:50:13Z" withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//
static NSDateFormatter *nsdate_json_dateFormatter;
static NSLocale *nsdate_json_locale;
static NSString *nsdate_json_lock = @"nsdate_json_lock";

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat {
    @synchronized(nsdate_json_lock) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            nsdate_json_dateFormatter = [[NSDateFormatter alloc] init]; 
            nsdate_json_locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        });

        // Ensuring to set set the locale, more info [here](http://developer.apple.com/library/ios/#qa/qa2010/qa1480.html)
        [nsdate_json_dateFormatter setLocale:nsdate_json_locale];
        [nsdate_json_dateFormatter setDateFormat:dateFormat];
        
        NSDate *date = [nsdate_json_dateFormatter dateFromString:dateString];
        return date;
    }
}

-(NSString *)formatToUTC {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [[dateFormatter stringFromDate:self] stringByAppendingString:@" UTC +00:00"];
    return dateString;
}



@end
