//
//  AppDelegate.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 28/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxLocator.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) BoxLocator *boxLocator;

@end
