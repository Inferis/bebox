//
//  PostBoxCell.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 02/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "PostBoxCell.h"
#import "UIColor+Hex.h"

@implementation PostBoxCell

- (id)initWithReuseIdentifier:(NSString*)identifier {
    if ((self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier])) {
        CAGradientLayer *gradient = (CAGradientLayer*)self.layer;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor whiteColor] CGColor],
                           [[UIColor colorWithHex:0xf2f2f2] CGColor],
                           nil];
        self.textLabel.opaque = NO;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 2;
        self.detailTextLabel.opaque = NO;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];

        self.imageView.highlightedImage = [UIImage imageNamed:@"postbox-hilite.png"];
    }
    return self;
}

- (void)configure:(PostBox*)box {
    self.textLabel.text = [NSString stringWithFormat:@"%@\n%@", box.addressNL[0], box.addressNL[1]];
    self.detailTextLabel.text = box.clearance;
    self.imageView.image = [UIImage imageNamed:[box hasClearanceScheduledForToday] ? @"postbox-open.png" : @"postbox-closed.png"];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}
@end
