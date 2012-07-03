//
//  PostBoxCell.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 02/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostBox.h"

@interface PostBoxCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString*)identifier;
- (void)configure:(PostBox*)postbox;

@end
