//
//  ClearanceCell.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 05/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostBox;

@interface ClearanceCell : UITableViewCell

- (void)configure:(PostBox*)box asSaturday:(BOOL)saturday;

@end
