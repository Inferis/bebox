//
//  BoxLocator.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "BoxLocator.h"
#import <CoreLocation/CoreLocation.h>

NSString* const kBoxLocatorPositionChanged = @"BoxLocatorPositionChanged";

@interface BoxLocator () <CLLocationManagerDelegate> {
}

@end

@implementation BoxLocator {
    CLLocationManager* _locationManager;
}

- (CLLocation *)location {
    return _locationManager.location;
}


- (id)init {
    if ((self = [super init])) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 250;
        [_locationManager startMonitoringSignificantLocationChanges];
        
        if (self.location)
            [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorPositionChanged object:self];
    }
    
    return self;
}

- (BOOL)locateBoxesFor:(CLLocationCoordinate2D)coordinate {
    if (self.isLocatingBoxes)
        return NO;
    
    _isLocatingBoxes = YES;
    
}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorPositionChanged object:self];
}

@end
