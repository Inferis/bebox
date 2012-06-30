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

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;

@end

@implementation MapViewController {
    CLLocationCoordinate2D* _currentCenter;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    if (!IsIPad()) {
        [self.viewDeckController openLeftViewAnimated:NO];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"list" style:UIBarButtonItemStyleDone target:self.viewDeckController action:@selector(toggleLeftView)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorUserPositionChanged object:nil];
}


- (void)boxesChanged:(NSNotification*)notification {
    NSArray* boxes = [(BoxLocator*)[notification object] locatedBoxes];
    boxes = [boxes map:^id(id box) {
        return [[PostBoxAnnotation alloc] initWithPostBox:box];
    }];
    
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotations:boxes];
    _mapView.centerCoordinate = _mapView.centerCoordinate;
    
}


- (void)locationChanged:(NSNotification*)notification {
    CLLocation* location = [(BoxLocator*)[notification object] userLocation];
    
    CLLocation* currentCenter = [[CLLocation alloc] initWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
    if ([currentCenter distanceFromLocation:location] > 10) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 150, 150);
        viewRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:viewRegion animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Map delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [BoxLox boxLocator].centerLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
}

@end
