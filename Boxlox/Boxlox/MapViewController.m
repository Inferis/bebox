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

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boxesChanged:) name:kBoxLocatorBoxesLocated object:nil];
    }
    return self;
}

- (UINavigationItem *)navigationItem {
    return [self.parentViewController navigationItem] ? [self.parentViewController navigationItem] : [super navigationItem];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"local" style:UIBarButtonItemStyleDone target:self action:@selector(toUserLocation)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    _first = YES;
    
    if (!IsIPad()) {
        [self.viewDeckController openLeftViewAnimated:NO];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"list" style:UIBarButtonItemStyleDone target:self.viewDeckController action:@selector(toggleLeftView)];
    }
    
    self.mapView.centerCoordinate = [[BoxLox boxLocator] centerLocation].coordinate;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorUserPositionChanged object:nil];
}

- (void)toUserLocation {
    _mapView.centerCoordinate = _mapView.userLocation.location.coordinate;
}

- (void)boxesChanged:(NSNotification*)notification {
    NSLog(@"boxes changed");
    NSArray* boxes = [(BoxLocator*)[notification object] allBoxes];
    NSArray* annotations = [boxes map:^id(id box) {
        return [[PostBoxAnnotation alloc] initWithPostBox:box];
    }];
    
    BOOL allowZoom = _mapView.annotations.count == 1;
    
    NSArray* existing = [_mapView.annotations ofClass:[PostBoxAnnotation class]];
    NSArray* new = [annotations select:^BOOL(PostBoxAnnotation* newAnnotation) {
        return ![existing any:^BOOL(PostBoxAnnotation* existingAnnotation) {
            return [existingAnnotation isKindOfClass:[PostBoxAnnotation class]] && [newAnnotation.postBox.id isEqualToString:existingAnnotation.postBox.id];
        }];
    }];
    
//    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotations:new];
    //_mapView.centerCoordinate = _mapView.centerCoordinate;
    
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
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    }
    else
        _mapView.centerCoordinate = _mapView.centerCoordinate;
    
    [self updateVisibleBoxes];
    
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

#pragma mark - Map delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self updateVisibleBoxes];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"did change");
    [BoxLox boxLocator].centerLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [self updateVisibleBoxes];
}


- (void)updateVisibleBoxes {
    NSArray* boxes = [[[[_mapView annotationsInMapRect:_mapView.visibleMapRect] allObjects] ofClass:[PostBoxAnnotation class]] valueForKey:@"postBox"];
    boxes = [[boxes toDictionaryUsingKeyField:@"id"] allValues];
    
    [self.boxMapDelegate mapView:_mapView didShowBoxes:boxes];
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

- (void)selectBox:(PostBox *)box {
    PostBoxAnnotation* selected = [[[[_mapView annotations] ofClass:[PostBoxAnnotation class] ] select:^BOOL(PostBoxAnnotation* pba) {
        return [pba.postBox.id isEqualToString:box.id];
    }] first];
    
    [_mapView selectAnnotation:selected animated:YES];
    _mapView.centerCoordinate = box.location.coordinate;
    [self.viewDeckController openLeftView];
}
@end
