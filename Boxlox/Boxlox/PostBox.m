//
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

- (NSString*)todaysClearance {
    int weekday = [[NSDate date] dayOfWeek];
    if (weekday == 1) {
        // sunday
        return nil;
    }
    
    if (weekday == 7) {
        // saturday
        return self.clearanceSaturday;
    }

    return self.clearance;
}

- (BOOL)hasClearanceScheduledForToday {
    NSString* time = [self todaysClearance];
    if (IsEmpty(time))
        return NO;
    
    return [time compare:[[NSDate date] formatAs:@"HH:mm"] options:NSCaseInsensitiveSearch] != NSOrderedAscending;
}

- (CLLocationDistance)distanceFromUserLocation {
    return [self.location distanceFromLocation:[BoxLox boxLocator].userLocation];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %0.2fm", self.fullAddressNL, self.location, [self distanceFromUserLocation]];
}
@end
