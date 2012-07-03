    //
//  BoxLocator.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "BoxLocator.h"
#import <CoreLocation/CoreLocation.h>
#import "Tin.h"
#import "TinResponse.h"
#import "XMLReader.h"
#import "PostBox.h"
#import "Coby.h"

NSString* const kBoxLocatorUserPositionChanged = @"BoxLocatorUserPositionChanged";
NSString* const kBoxLocatorBoxesLocated = @"BoxLocatorBoxesLocated";
NSString* const kBoxLocatorBoxesLocating = @"BoxLocatorBoxesLocating";

@interface BoxLocator () <CLLocationManagerDelegate> {
}

@end

@implementation BoxLocator {
    CLLocationManager* _locationManager;
    NSOperationQueue* _lookupQueue;
    NSMutableDictionary* _allBoxes;
}

- (CLLocation *)userLocation {
    return _locationManager.location;
}

- (NSArray *)allBoxes {
    return [_allBoxes allValues];
}

- (void)setCenterLocation:(CLLocation *)centerLocation {
    CLLocationDistance distance = [centerLocation distanceFromLocation:_centerLocation];
    if (!_centerLocation || distance >= 250) {
        [self locateBoxesFor:centerLocation.coordinate];
    }
    _centerLocation = centerLocation;
}

- (id)init {
    if ((self = [super init])) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 250;
        [_locationManager startUpdatingLocation];
                
        _lookupQueue = [NSOperationQueue new];
        _lookupQueue.maxConcurrentOperationCount = 1;
        
        _allBoxes = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)locateBoxesFor:(CLLocationCoordinate2D)coordinate {
    if (_lookupQueue.operationCount == 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorBoxesLocating object:self];

    [_lookupQueue cancelAllOperations]; // remove previous lookups
    
    __block NSOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"started");
        [NSThread sleepForTimeInterval:0.3];
        
        if ([operation isCancelled])
            return;
        
        NSLog(@"started2");
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:coordinate.latitude], @"lat", [NSNumber numberWithDouble:coordinate.longitude], @"lng", nil];
        
        TinResponse* response = [Tin get:@"http://www.bpost2.be/redboxes/nl/get_boxes.php" query:query];
        NSDictionary* parsed = [XMLReader dictionaryForXMLData:response.body error:nil];
        NSArray* markers = [[parsed objectForKey:@"markers"] objectForKey:@"marker"];
        if (markers) {
            [self handleMarkers:markers];
        }
        NSLog(@"done");
        [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorBoxesLocated object:self];
    }];
    [_lookupQueue addOperation:operation];
}

- (void)handleMarkers:(NSArray*)parsedMarkers {
    _locatedBoxes = [parsedMarkers map:^id(id obj) {
        PostBox* box = [PostBox new];
        box.id = [NSString stringWithFormat:@"%@", [obj objectForKey:@"id"]];
        box.addressNL = [NSArray arrayWithObjects:[obj objectForKey:@"address1_nl"], [obj objectForKey:@"address2_nl"], nil];
        box.addressFR = [NSArray arrayWithObjects:[obj objectForKey:@"address1_fr"], [obj objectForKey:@"address2_fr"], nil];
        box.location = [[CLLocation alloc] initWithLatitude:[[obj objectForKey:@"lat"] doubleValue] longitude:[[obj objectForKey:@"lng"] doubleValue]];
        box.clearance = [obj objectForKey:@"week"];
        box.clearanceSaturday =[obj objectForKey:@"sat"];
        return box;
    }];
    
    [_locatedBoxes each:^(PostBox* box) {
        if (![_allBoxes objectForKey:box.id])
            [_allBoxes setObject:box forKey:box.id];
    }];
}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (_centerLocation) {
        CLLocationDistance distance = [newLocation distanceFromLocation:_centerLocation];
        if (distance < 50)
            return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorUserPositionChanged object:self];
    self.centerLocation = newLocation;
}

@end
