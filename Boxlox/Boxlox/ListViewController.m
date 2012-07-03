//
//  ListViewController.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 29/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "ListViewController.h"
#import "BoxMapDelegate.h"
#import "Coby.h"
#import <MapKit/MapKit.h>
#import "PostBox.h"
#import "UITableViewCell+AutoDequeue.h"
#import "PostBoxCell.h"

@interface ListViewController ()

@end

@implementation ListViewController {
    NSArray* _boxes;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = self.tableView.rowHeight/2.0 * 3.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"listbackground.png"] resizableImageWithCapInsets:UIEdgeInsetsZero]];
}

- (void)mapView:(MKMapView *)mapView didShowBoxes:(NSArray *)boxes {
    NSArray* oldBoxes = _boxes;
    
    _boxes = [boxes sortedArrayUsingComparator:^NSComparisonResult(PostBox* obj1, PostBox* obj2) {
        BOOL c1 = [obj1 hasClearanceScheduledForToday];
        BOOL c2 = [obj2 hasClearanceScheduledForToday];
        if (c1 && !c2) return NSOrderedAscending;
        if (!c1 && c2) return NSOrderedDescending;
        
        CLLocationDistance d1 = [mapView.userLocation.location distanceFromLocation:obj1.location];
        CLLocationDistance d2 = [mapView.userLocation.location distanceFromLocation:obj2.location];
        
        return d1 == d2 ? NSOrderedSame : d1 < d2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSArray* deleted = nil;
    NSArray* inserted = nil;
    if (IsEmpty(oldBoxes)) {
        inserted = [[_boxes allIndices] map:^id(NSNumber* row) {
            return [NSIndexPath indexPathForRow:[row intValue] inSection:0];
        }];
    }
    else {
        deleted = [[oldBoxes selectIndex:^BOOL(PostBox* ob) {
            return ![_boxes any:^BOOL(PostBox* nb) {
                return [ob.id isEqualToString:nb.id];
            }];
        }] map:^id(NSNumber* row) {
            return [NSIndexPath indexPathForRow:[row intValue] inSection:0];
        }];
        
        inserted = [[_boxes selectIndex:^BOOL(PostBox* nb) {
            return ![oldBoxes any:^BOOL(PostBox* ob) {
                return [ob.id isEqualToString:nb.id];
            }];
        }] map:^id(NSNumber* row) {
            return [NSIndexPath indexPathForRow:[row intValue] inSection:0];
        }];
        
    }
    
    [self.tableView beginUpdates];
    if (!IsEmpty(deleted)) [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationTop];
    if (!IsEmpty(inserted)) [self.tableView insertRowsAtIndexPaths:inserted withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_boxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostBoxCell *cell = [PostBoxCell tableViewAutoDequeueCell:self.tableView];
    
    PostBox* box = _boxes[indexPath.row];
    [cell configure:box];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.boxSelectionDelegate selectBox:_boxes[indexPath.row]];
}

@end
