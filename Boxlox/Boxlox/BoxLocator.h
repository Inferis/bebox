//
//  BoxLocator.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

extern NSString* const kBoxLocatorPositionChanged;

@interface BoxLocator : NSObject

@property (nonatomic, readonly, retain) CLLocation* location;
@property (nonatomic, readonly, assign) BOOL isLocatingBoxes;

- (BOOL)locateBoxesFor:(CLLocationCoordinate2D)coordinate;

@end
