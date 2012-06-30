//
//  PostBoxAnnotation.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 30/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PostBox.h"

@interface PostBoxAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) PostBox* postBox;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithPostBox:(PostBox*)postBox;
@end
