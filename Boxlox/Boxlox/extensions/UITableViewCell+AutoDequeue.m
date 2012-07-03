//
//  UITableViewCell+AutoDequeue.m
//  Faering
//
//  Created by Tom Adriaenssen on 12/02/12.
//  Copyright (c) 2012 10to1, Interface Implementation. All rights reserved.
//

#import "UITableViewCell+AutoDequeue.h"
#import <objc/message.h>

@implementation UITableViewCell (AutoDequeue)

+ (id)tableViewAutoDequeueCell:(UITableView*)tableView {
    NSString *cellIdentifier = NSStringFromClass(self);
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [self alloc];
        SEL initSelector = @selector(initWithReuseIdentifier:);
        if ([cell respondsToSelector:initSelector]) {
            cell = objc_msgSend(cell, initSelector, cellIdentifier);
            // was: cell = [cell performSelector:@selector(initWithReuseIdentifier:) withObject:cellIdentifier];
            // but xcode 4.5 barfed on it (ARC)
        }
        else
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

+ (void)tableViewRegisterAutoDequeueFromNib:(UITableView*)tableView {
    NSString *cellIdentifier = NSStringFromClass(self);
    [tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
}


@end
