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

@interface MapViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UIButton* mapModeButton;

@end

@implementation MapViewController {
    CLLocationCoordinate2D* _currentCenter;
    BOOL _following, _first;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:) name:kBoxLocatorUserPositionChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boxesLocating) name:kBoxLocatorBoxesLocating object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boxesLocated:) name:kBoxLocatorBoxesLocated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationStatusChanged:) name:kBoxLocatorUserPositionStatusChanged object:nil];
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
    
    UIPanGestureRecognizer* panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panner.delaysTouchesBegan = NO;
    panner.delaysTouchesEnded = NO;
    panner.delegate = self;
    [_mapView addGestureRecognizer:panner];
    
    if (!IsIPad())
        [self.viewDeckController openLeftViewAnimated:NO];
    
    self.mapView.centerCoordinate = [[BoxLox boxLocator] centerLocation].coordinate;
}

-(void)updateLeftBarButtonItems {
    if ([BoxLox boxLocator].canLocateUser) {
        UIImage* image, *hiImage;
        if (_following) {
            image = [UIImage imageNamed:@"compass-on.png"];
            hiImage = [UIImage imageNamed:@"compass-on-hi.png"];
        }
        else {
            image = [UIImage imageNamed:@"compass.png"];
            hiImage = [UIImage imageNamed:@"compass-hi.png"];
        }
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(toUserLocation) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:hiImage forState:UIControlStateHighlighted];
        button.frame = (CGRect) { 0, 0, image.size };
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else
        self.navigationItem.leftBarButtonItem = nil;
}

- (void)updateRightBarButtonItems {
    if (!IsIPad()) {
        UIImage* image = [UIImage imageNamed:@"list.png"];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"list-hi.png"] forState:UIControlStateHighlighted];
        [button addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        button.frame = (CGRect) { 0, 0, image.size };
 
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorBoxesLocating object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorBoxesLocated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorUserPositionChanged object:nil];
}

- (void)toUserLocation {
    if ([self.viewDeckController leftControllerIsClosed]) {
        [self.viewDeckController openLeftView];
    }
    
    if (_following) {
        _following = NO;
        [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
    else {
        CLLocation* mc = [[CLLocation alloc] initWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
        CLLocation* uc = _mapView.userLocation.location;
        _mapView.centerCoordinate = uc.coordinate;
        if ([mc distanceFromLocation:uc] < 25) {
            [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
            _following = YES;
        }
    }
    
    [self updateLeftBarButtonItems];
    [self updateRightBarButtonItems];
}

- (void)boxesLocating {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self updateVisibleBoxes];
        });
    });
}


- (void)locationStatusChanged:(NSNotification*)notification {
    if (![BoxLox boxLocator].canLocateUser && _following) {
        _following = NO;
        [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
    
    [self updateLeftBarButtonItems];
}

- (void)locationChanged:(NSNotification*)notification {
    CLLocation* location = [(BoxLocator*)[notification object] userLocation];
    
    if (_first) {
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
    [self.viewDeckController openLeftView];
}

- (void)showBoxDetails:(PostBox *)box from:(UIView*)control {
}

#pragma mark - Gesture recognizer

- (void)panned:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _following = NO;
        [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
        [self updateLeftBarButtonItems];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Map delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self updateVisibleBoxes];
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self showBoxDetails:((PostBoxAnnotation*)view.annotation).postBox from:control];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (![annotation isKindOfClass:[PostBoxAnnotation class]])
        return nil;
    
    PostBoxAnnotationView* pin = [[PostBoxAnnotationView alloc] initWithAnnotation:annotation];
    pin.canShowCallout = YES;
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
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

#pragma mark - map mode

- (IBAction)changeMapMode:(id)sender {
    CGRect originalFrame = _mapModeButton.frame;
    [UIView animateWithDuration:0.08 animations:^{
        _mapModeButton.frame = CGRectOffset(originalFrame, 0, -2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            // move it down
            _mapModeButton.frame = CGRectOffset(originalFrame, 0, 80);
        } completion:^(BOOL finished) {
            _mapView.mapType = _mapView.mapType != MKMapTypeStandard ? MKMapTypeStandard : MKMapTypeHybrid;
            [_mapModeButton setTitle:_mapView.mapType == MKMapTypeStandard ? @"Standard" : @"Hybrid" forState:UIControlStateNormal];
            [UIView animateWithDuration:0.16 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                // move it down
                _mapModeButton.frame = CGRectOffset(originalFrame, 0, -2);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.08 animations:^{
                    _mapModeButton.frame = originalFrame;
                }];
            }];
        }];
    }];
}


@end
