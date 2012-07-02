//
//  PostBoxAnnotationView.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 01/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PostBoxAnnotation;

@interface PostBoxAnnotationView : MKAnnotationView

- (id)initWithAnnotation:(PostBoxAnnotation*)annotation;

@end
