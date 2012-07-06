//
//  ButtonCell.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 05/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonCell : UITableViewCell

- (void)configureWithText:(NSString*)text action:(void(^)())action;

@end
