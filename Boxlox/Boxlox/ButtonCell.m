//
//  ButtonCell.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 05/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "ButtonCell.h"
#import "UIColor+Hex.h"

@implementation ButtonCell {
    void(^_action)();
    UIButton *_button;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _button.frame = CGRectMake(-1.0f, -1.0f, self.bounds.size.width - 18.0f, 41.0f);
        [_button setBackgroundImage:[[UIImage imageNamed:@"detail-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitleShadowColor:[UIColor colorWithHex:0x1e4f6b] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_button setTitleShadowColor:[UIColor colorWithHex:0x1e4f6b] forState:UIControlStateHighlighted];
        _button.titleLabel.shadowOffset = (CGSize) { 0, -1 };
        
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_button];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backView;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)buttonPressed
{
    if (_action) _action();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _button.frame = CGRectMake(-1.0f, -1.0f, self.bounds.size.width - 18.0f, 41.0f);
}

- (void)configureWithText:(NSString*)text action:(void(^)())action {
    [_button setTitle:text forState:UIControlStateNormal];
    _action = [action copy];
}

@end
