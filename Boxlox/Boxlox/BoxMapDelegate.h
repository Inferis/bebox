//
//  BoxMapDelegate.h
//  Boxlox
//
//  Created by Tom Adriaenssen on 02/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKMapView;
@class PostBox;

@protocol BoxMapDelegate <NSObject>

- (void)mapView:(MKMapView*)mapView didShowBoxes:(NSArray*)boxes;

@end

@protocol BoxSelectionDelegate <NSObject>

- (void)selectBox:(PostBox*)box;
- (void)showBoxDetails:(PostBox*)box from:(UIView*)control;

@end
