//
//  BoxLocator.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString* const kBoxLocatorUserPositionChanged;
extern NSString* const kBoxLocatorBoxesLocated;

@interface BoxLocator : NSObject

@property (nonatomic, readonly, retain) CLLocation* userLocation;
@property (nonatomic, retain) CLLocation* centerLocation;
@property (nonatomic, readonly, retain) NSArray* locatedBoxes;

- (void)locateBoxesFor:(CLLocationCoordinate2D)coordinate;

@end
