//
//  PadViewController.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "PadViewController.h"
#import "ListViewController.h"
#import "MapViewController.h"

@interface PadViewController ()

@property (nonatomic, weak, readwrite) IBOutlet UIView* mapContainerView;
@property (nonatomic, weak, readwrite) IBOutlet UIView* listContainerView;
@property (nonatomic, retain, readwrite) ListViewController* listViewController;
@property (nonatomic, retain, readwrite) MapViewController* mapViewController;

@end

@implementation PadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.listViewController = nil;
    self.mapViewController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listViewController = [[ListViewController alloc] initWithNibName:nil bundle:nil];
    [self.listContainerView addSubview:self.listViewController.view];
    self.listViewController.view.frame = self.listContainerView.bounds;

    UIView* shadowedView = self.listContainerView;
    shadowedView.layer.masksToBounds = NO;
    shadowedView.layer.shadowRadius = 10;
    shadowedView.layer.shadowOpacity = 0.5;
    shadowedView.layer.shadowColor = [[UIColor blackColor] CGColor];
    shadowedView.layer.shadowOffset = CGSizeZero;
    shadowedView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowedView.bounds] CGPath];
    
    self.mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    [self.mapContainerView addSubview:self.mapViewController.view];
    self.mapViewController.view.frame = self.mapContainerView.bounds;
}


@end
