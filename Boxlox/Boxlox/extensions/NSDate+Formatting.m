//
//  NSDate+Formatting.m
//
//  27/06/11.
//  Copyright 2011. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

-(NSString *)lockedFormat:(NSString*(^)(NSDateFormatter* formatter))formatting {
    static NSString* formatterLock = @"formatterLock";
    static NSDateFormatter* dateFormatter = nil;
    @synchronized(formatterLock) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
        });
        
        return formatting(dateFormatter);
    }
}

-(NSString *)formatWithStyle:(NSDateFormatterStyle)style {
    return [self lockedFormat:^(NSDateFormatter* dateFormatter) {
        [dateFormatter setDateStyle:style];
        return [dateFormatter stringFromDate:self];
    }];
}

-(NSString *)formatAs:(NSString*)format {
    return [self lockedFormat:^(NSDateFormatter* dateFormatter) {
        [dateFormatter setDateFormat:format];
        return [dateFormatter stringFromDate:self];
    }];
}

-(NSString *)formatAsDateOnly {
    return [self formatAs:@"yyyy-MM-dd"];
}

-(NSString *)formatAsDateOnlyRelative {
    NSString* formatted = [self formatAsDateOnly];
    if ([[[NSDate date] formatAsDateOnly] isEqualToString:formatted]) 
        return NSLocalizedString(@"today", @"Today");
    
    NSTimeInterval day = 24*60*60;
    if ([[[[NSDate date] dateByAddingTimeInterval:day] formatAsDateOnly] isEqualToString:formatted]) {
        return NSLocalizedString(@"tomorrow", @"Tomorrow");
    }
    if ([[[[NSDate date] dateByAddingTimeInterval:-day] formatAsDateOnly] isEqualToString:formatted]) {
        return NSLocalizedString(@"yesterday", @"Yesterday");
    }
    
    return formatted;
}
@end
