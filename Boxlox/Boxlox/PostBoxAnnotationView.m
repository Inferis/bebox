//
//  PostBoxAnnotationView.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 01/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "PostBoxAnnotationView.h"
#import "PostBox.h"
#import "PostBoxAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostBoxAnnotationView

- (id)initWithAnnotation:(PostBoxAnnotation*)annotation {
    self = [super initWithAnnotation:annotation reuseIdentifier:@"PostBox"];
    if (self) {
        UIImage* image = [UIImage imageNamed:[annotation.postBox hasClearanceScheduledForToday] ? @"postbox-open.png" : @"postbox-closed.png"];
        self.layer.contents = (id)[image CGImage];
        self.frame = (CGRect) { 0, 0, 24, 24 };
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

- (void)setAnnotation:(PostBoxAnnotation*)annotation {
    [super setAnnotation:annotation];
    UIImage* image = [UIImage imageNamed:[annotation.postBox hasClearanceScheduledForToday] ? @"postbox-open.png" : @"postbox-closed.png"];
    self.layer.contents = (id)[image CGImage];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
