//
//  PostBox.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 30/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostBox : NSObject

@property (nonatomic, assign) uint id;
@property (nonatomic, retain) NSString* addressNL;
@property (nonatomic, retain) NSString* addressFR;
@property (nonatomic, retain) CLLocation* location;

@end
