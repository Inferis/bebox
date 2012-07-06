//
//  ClearanceCell.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 05/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "ClearanceCell.h"
#import "PostBox.h"
#import "NSDate+Extensions.h"

@implementation ClearanceCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)configure:(PostBox*)box asSaturday:(BOOL)saturday {
    int dayofweek = [[NSDate date] dayOfWeek];
    self.detailTextLabel.text = @"";
    if ([box hasClearanceScheduledForToday]) {
        self.imageView.image = [UIImage imageNamed:@"postbox-open.png"];
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"postbox-closed.png"];
        if ((dayofweek == 7) == saturday && dayofweek != 1) // saturday
            self.detailTextLabel.text = @"Last clearance passed";
    }

    if (saturday) {
        self.textLabel.text =  [NSString stringWithFormat:@"On saturday: %@", [box clearanceSaturday]];
    }
    else {
        self.textLabel.text =  [NSString stringWithFormat:@"On weekdays: %@", [box clearance]];
    }
}

@end
