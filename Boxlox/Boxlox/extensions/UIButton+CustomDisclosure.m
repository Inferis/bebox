//
//  UIButton+CustomDisclosure.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 07/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "UIButton+CustomDisclosure.h"

@implementation UIButton (CustomDisclosure)

+ (UIButton*)customDisclosureButton {
    UIImage* image = [UIImage imageNamed:@"disclosure.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.opaque = NO;
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"disclosure-hi.png"] forState:UIControlStateHighlighted];
    button.frame = (CGRect) { 0, 0, image.size };
    return button;
}
@end
