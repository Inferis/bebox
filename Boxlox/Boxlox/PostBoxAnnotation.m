//
//  PostBoxAnnotation.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 30/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "PostBoxAnnotation.h"

@implementation PostBoxAnnotation

- (id)initWithPostBox:(PostBox*)postBox {
    if ((self = [self init])) {
        _postBox = postBox;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return _postBox.location.coordinate;
}

- (NSString *)title {
    return _postBox.addressNL[0];
}

- (NSString *)subtitle {
    return _postBox.addressNL[1];
}

@end
