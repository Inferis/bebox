x//
//  PostBox.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 30/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "PostBox.h"
#import "NSDate+Extensions.h"
#import "NSDate+Formatting.h"

@implementation PostBox

- (NSString *)fullAddressNL {
    return [self.addressNL componentsJoinedByString:@", "];
}

- (NSString *)fullAddressFR {
    return [self.addressFR componentsJoinedByString:@", "];
}

- (BOOL)hasClearanceScheduledForToday {
    int weekday = [[NSDate date] dayOfWeek];
    if (weekday == 1) {
        // sunday
        return NO;
    }
    
    NSString* time;
    if (weekday == 7) {
        // saturday
        time = self.clearanceSaturday;
    }
    else {
        time = self.clearance;
    }
    
    if (IsEmpty(time))
        return NO;
    
    
    return [time compare:[[NSDate date] formatAs:@"HH:mm"] options:NSCaseInsensitiveSearch] != NSOrderedAscending;
}

@end
