//
//  PostBoxCell.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 02/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "PostBoxCell.h"
#import "UIColor+Hex.h"
#import "NSDate+Extensions.h"

@implementation PostBoxCell {
    UILabel* _distanceLabel;
    CGSize _distanceLabelSize;
}

- (id)initWithReuseIdentifier:(NSString*)identifier {
    if ((self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier])) {
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        CAGradientLayer *gradient = (CAGradientLayer*)self.layer;
        gradient.colors = @[(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithHex:0xf2f2f2] CGColor], (id)[[UIColor colorWithHex:0xcccccc] CGColor]];
        gradient.locations = @[@0, @0.99, @1];
        self.textLabel.opaque = NO;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 2;
        self.detailTextLabel.opaque = NO;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.font = [UIFont systemFontOfSize:12];
        _distanceLabel.textColor = [UIColor colorWithHex:0x888888];
        _distanceLabel.backgroundColor = [UIColor clearColor];
        _distanceLabel.layer.cornerRadius = 3;
        _distanceLabel.textAlignment = UITextAlignmentCenter;
        _distanceLabel.opaque = NO;
        [[self contentView] addSubview:_distanceLabel];

        self.imageView.highlightedImage = [UIImage imageNamed:@"postbox-hilite-noshadow.png"];
    }
    return self;
}

- (void)configure:(PostBox*)box {
    self.textLabel.text = [NSString stringWithFormat:@"%@\n%@", box.addressNL[0], box.addressNL[1]];
    self.detailTextLabel.text = @"No clearance today";

    int dayOfWeek = [[NSDate date] dayOfWeek];
    if (dayOfWeek != 1) {
        if ([box hasClearanceScheduledForToday])
            self.detailTextLabel.text = [NSString stringWithFormat:@"Last clearance: %@", [box todaysClearance]];
        else if (!IsEmpty([box todaysClearance]))
            self.detailTextLabel.text = [NSString stringWithFormat:@"Last cleared: %@", [box todaysClearance]];
    }
    
    self.imageView.image = [UIImage imageNamed:[box hasClearanceScheduledForToday] ? @"postbox-open-noshadow.png" : @"postbox-closed-noshadow.png"];
    
    if ([BoxLox boxLocator].canLocateUser) {
        CLLocationDistance distance = [box.location distanceFromLocation:[BoxLox boxLocator].userLocation];
        if (distance >= 1000) {
            _distanceLabel.text = [NSString stringWithFormat:@"%0.1fkm", distance/1000.0];
        }
        else {
            _distanceLabel.text = [NSString stringWithFormat:@"%0.fm", distance];
        }
        _distanceLabelSize = [_distanceLabel.text sizeWithFont:_distanceLabel.font];
    }
    else
        _distanceLabelSize = CGSizeZero;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _distanceLabel.frame = (CGRect) { CGRectGetMidX(self.imageView.frame)-_distanceLabelSize.width/2, self.detailTextLabel.frame.origin.y - 5, _distanceLabelSize };
    
    self.imageView.frame = CGRectOffset(self.imageView.frame, 0, -8);
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end
