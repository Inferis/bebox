//
//  DetailViewController.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 05/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostBox;

@interface DetailViewController : UITableViewController

- (id)initWithPostBox:(PostBox*)postBox;

@end
