//
//  PostBox.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 30/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostBox : NSObject

@property (nonatomic, assign) NSString* id;
@property (nonatomic, retain) NSArray* addressNL;
@property (nonatomic, retain) NSArray* addressFR;
@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, retain) NSString* clearance;
@property (nonatomic, retain) NSString* clearanceSaturday;

@property (nonatomic, retain, readonly) NSString* fullAddressNL;
@property (nonatomic, retain, readonly) NSString* fullAddressFR;

- (BOOL)hasClearanceScheduledForToday;

@end
