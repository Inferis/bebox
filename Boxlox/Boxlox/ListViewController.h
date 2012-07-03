//
//  ListViewController.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxMapDelegate.h"

@interface ListViewController : UITableViewController <BoxMapDelegate>

@property (nonatomic, weak) id<BoxSelectionDelegate> boxSelectionDelegate;

@end
