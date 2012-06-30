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

@interface BoxLocator () <CLLocationManagerDelegate> {
}

@end

@implementation BoxLocator {
    CLLocationManager* _locationManager;
    NSOperationQueue* _lookupQueue;
}

- (CLLocation *)userLocation {
    return _locationManager.location;
}


- (void)setCenterLocation:(CLLocation *)centerLocation {

    CLLocationDistance distance = [centerLocation distanceFromLocation:_centerLocation];
    if (distance >= 250) {
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
    }
    
    return self;
}

- (void)locateBoxesFor:(CLLocationCoordinate2D)coordinate {
    [_lookupQueue cancelAllOperations]; // remove previous lookups
    
    [_lookupQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:coordinate.latitude], @"lat", [NSNumber numberWithDouble:coordinate.longitude], @"lng", nil];
        
        TinResponse* response = [Tin get:@"http://www.bpost2.be/redboxes/nl/get_boxes.php" query:query];
        NSDictionary* parsed = [XMLReader dictionaryForXMLData:response.body error:nil];
        NSArray* markers = [[parsed objectForKey:@"markers"] objectForKey:@"marker"];
        if (markers) {
            [self handleMarkers:markers];
        }
    }]];
}

- (void)handleMarkers:(NSArray*)parsedMarkers {
    _locatedBoxes = [parsedMarkers map:^id(id obj) {
        PostBox* box = [PostBox new];
        box.id = [[obj objectForKey:@"id"] intValue];
        box.addressNL = [NSString stringWithFormat:@"%@, %@", [obj objectForKey:@"address1_nl"], [obj objectForKey:@"address2_nl"]];
        box.addressFR = [NSString stringWithFormat:@"%@, %@", [obj objectForKey:@"address1_fr"], [obj objectForKey:@"address2_fr"]];
        box.location = [[CLLocation alloc] initWithLatitude:[[obj objectForKey:@"lat"] doubleValue] longitude:[[obj objectForKey:@"lng"] doubleValue]];
        return box;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorBoxesLocated object:self];
}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kBoxLocatorUserPositionChanged object:self];
    
    if (_centerLocation) {
        CLLocationDistance distance = [newLocation distanceFromLocation:_centerLocation];
        if (distance < 250)
            return;
    }
    
    self.centerLocation = newLocation;
}

@end
