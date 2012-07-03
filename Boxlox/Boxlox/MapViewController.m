//
//  MapViewController.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "MapViewController.h"
#import "IIViewDeckController.h"
#import "BoxLocator.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "PostBox.h"
#import "PostBoxAnnotation.h"
#import "Coby.h"
#import "PostBoxAnnotationView.h"
#import "BoxMapDelegate.h"
#import "UIColor+Hex.h"

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;

@end

@implementation MapViewController {
    CLLocationCoordinate2D* _currentCenter;
    BOOL _following, _first;
    UIActivityIndicatorView* _spinner;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:) name:kBoxLocatorUserPositionChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boxesLocating) name:kBoxLocatorBoxesLocating object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boxesLocated:) name:kBoxLocatorBoxesLocated object:nil];
    }
    return self;
}

- (UINavigationItem *)navigationItem {
    return [self.parentViewController navigationItem] ? [self.parentViewController navigationItem] : [super navigationItem];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self updateLeftBarButtonItems];
    [self updateRightBarButtonItems];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    _first = YES;
    _following = NO;
    _mapView.userTrackingMode = MKUserTrackingModeNone;

    if (!IsIPad())
        [self.viewDeckController openLeftViewAnimated:NO];
    
    self.mapView.centerCoordinate = [[BoxLox boxLocator] centerLocation].coordinate;
}

-(void)updateLeftBarButtonItems {
    if (_following) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compass-on.png"] style:UIBarButtonItemStyleDone target:self action:@selector(toUserLocation)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithHex:0x8a5aa5];
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compass.png"] style:UIBarButtonItemStyleDone target:self action:@selector(toUserLocation)];
    }
}

- (void)updateRightBarButtonItems {
    if (!IsIPad()) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStyleDone target:self.viewDeckController action:@selector(toggleLeftView)],
                                                   [[UIBarButtonItem alloc] initWithCustomView:_spinner],
                                                   nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_spinner];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorBoxesLocating object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorBoxesLocated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorUserPositionChanged object:nil];
}

- (void)toUserLocation {
    if (_following) {
        _following = NO;
        _mapView.userTrackingMode = MKUserTrackingModeNone;
    }
    else {
        _mapView.centerCoordinate = _mapView.userLocation.location.coordinate;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        _following = YES;
    }
    
    [self updateLeftBarButtonItems];
    [self updateRightBarButtonItems];
}

- (void)boxesLocating {
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _spinner.hidesWhenStopped = NO;
    _spinner.layer.opacity = 0;
    [_spinner startAnimating];
    
    [self updateRightBarButtonItems];

    [UIView animateWithDuration:0.15 animations:^{
        _spinner.layer.opacity = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)boxesLocated:(NSNotification*)notification {
    dispatch_async_bg(^{
        NSArray* boxes = [(BoxLocator*)[notification object] allBoxes];
        NSArray* annotations = [boxes map:^id(id box) {
            return [[PostBoxAnnotation alloc] initWithPostBox:box];
        }];
        
        NSArray* existing = [_mapView.annotations ofClass:[PostBoxAnnotation class]];
        NSArray* new = [annotations select:^BOOL(PostBoxAnnotation* newAnnotation) {
            return ![existing any:^BOOL(PostBoxAnnotation* existingAnnotation) {
                return [existingAnnotation isKindOfClass:[PostBoxAnnotation class]] && [newAnnotation.postBox.id isEqualToString:existingAnnotation.postBox.id];
            }];
        }];
        
        BOOL allowZoom = !_following && _mapView.annotations.count <= 1;
        MKCoordinateRegion region;
        if (allowZoom) {
            CLLocationDegrees minLng, maxLng;
            CLLocationDegrees minLat, maxLat;
            BOOL first = YES;
            for (PostBox* box in boxes) {
                if (first) {
                    first = NO;
                    minLat = maxLat = box.location.coordinate.latitude;
                    minLng = maxLng = box.location.coordinate.longitude;
                }
                else {
                    if (box.location.coordinate.latitude > maxLat) maxLat = box.location.coordinate.latitude;
                    if (box.location.coordinate.latitude < minLat) minLat = box.location.coordinate.latitude;
                    if (box.location.coordinate.longitude > maxLng) maxLng = box.location.coordinate.longitude;
                    if (box.location.coordinate.longitude < minLng) minLng = box.location.coordinate.longitude;
                }
            }
            
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLng +minLng) / 2.0);
            MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat, maxLng - minLng);
            region = MKCoordinateRegionMake(center, span);
        }

        dispatch_async_main(^{
            [_mapView addAnnotations:new];
            
            if (allowZoom) {
                [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
            }
            else
                _mapView.centerCoordinate = _mapView.centerCoordinate;
            
            [UIView animateWithDuration:0.15 animations:^{
                _spinner.layer.opacity = 0;
            } completion:^(BOOL finished) {
                [_spinner stopAnimating];
                _spinner = nil;
                [self updateRightBarButtonItems];
            }];
            
            [self updateVisibleBoxes];
        });
    });
}


- (void)locationChanged:(NSNotification*)notification {
    CLLocation* location = [(BoxLocator*)[notification object] userLocation];
    
    if (_following || _first) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 150, 150);
        viewRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:viewRegion animated:YES];
        _first = NO;

        [self updateVisibleBoxes];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Helpers

- (void)updateVisibleBoxes {
    NSArray* boxes = [[[[_mapView annotationsInMapRect:_mapView.visibleMapRect] allObjects] ofClass:[PostBoxAnnotation class]] valueForKey:@"postBox"];
    boxes = [[boxes toDictionaryUsingKeyField:@"id"] allValues];
    
    [self.boxMapDelegate mapView:_mapView didShowBoxes:boxes];
}

#pragma mark - map selection delegate

- (void)selectBox:(PostBox *)box {
    PostBoxAnnotation* selected = [[[[_mapView annotations] ofClass:[PostBoxAnnotation class] ] select:^BOOL(PostBoxAnnotation* pba) {
        return [pba.postBox.id isEqualToString:box.id];
    }] first];
    
    [_mapView selectAnnotation:selected animated:YES];
    _mapView.centerCoordinate = box.location.coordinate;
    [self.viewDeckController openLeftView];
}

#pragma mark - Map delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self updateVisibleBoxes];
    _mapView.userTrackingMode = MKUserTrackingModeNone;
    _following = NO;
    [self updateLeftBarButtonItems];
    [self updateRightBarButtonItems];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (_first)
        return;
    
    NSLog(@"did change %f:%f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    [BoxLox boxLocator].centerLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [self updateVisibleBoxes];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (![annotation isKindOfClass:[PostBoxAnnotation class]])
        return nil;
    
    PostBoxAnnotationView* pin = [[PostBoxAnnotationView alloc] initWithAnnotation:annotation];
    
    PostBoxAnnotation* box = (PostBoxAnnotation*)annotation;
    pin.canShowCallout = YES;
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    pin.rightCalloutAccessoryView = rightButton;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    CGFloat delay = 0;
    
    CLLocation* center = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    views = [views sortedArrayUsingComparator:^NSComparisonResult(PostBoxAnnotationView* obj1, PostBoxAnnotationView* obj2) {
        CLLocationDistance d1 =  [((PostBoxAnnotation*)obj1.annotation).postBox.location distanceFromLocation:center];
        CLLocationDistance d2 =  [((PostBoxAnnotation*)obj2.annotation).postBox.location distanceFromLocation:center];
        return d1 == d2 ? NSOrderedSame : d1 < d2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    for (UIView* view in views) {
        CGRect endFrame = view.frame;

        view.frame = CGRectInset(view.frame, 10, 10);
        view.layer.opacity = 0.2;
        [UIView animateWithDuration:0.12 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            view.layer.opacity = 1;
            view.frame = CGRectInset(view.frame, 2, 2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^(void) {
                view.frame = CGRectInset(view.frame, -1, -1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.075 animations:^(void) {
                    view.frame = endFrame;
                }];
            }];
        }];
        delay += 0.1;
    }
}

@end
