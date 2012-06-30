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

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:) name:kBoxLocatorPositionChanged object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBoxLocatorPositionChanged object:nil];
}


- (void)locationChanged:(NSNotification*)notification {
    CLLocation* location = [(BoxLocator*)[notification object] location];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 150, 150);
    viewRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:viewRegion animated:YES];
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

@end
