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
#import "IIViewDeckController.h"

@interface ListViewController ()

@end

@implementation ListViewController {
    NSArray* _boxes;
    NSTimer* _followingUpdateTimer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[BoxLox boxLocator] addObserver:self forKeyPath:@"userLocation" options:0 context:nil];
    
    self.tableView.rowHeight = self.tableView.rowHeight/2.0 * 3.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"listbackground.png"] resizableImageWithCapInsets:UIEdgeInsetsZero]];
}

- (void)dealloc {
    [[BoxLox boxLocator] removeObserver:self forKeyPath:@"userLocation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![keyPath isEqualToString:@"userLocation"])
        return;
    
    [self updateBoxes:_boxes];
}

- (void)mapView:(MKMapView *)mapView didShowBoxes:(NSArray *)boxes {
    [self updateBoxes:boxes];
}

- (void)updateBoxes:(NSArray *)boxes {
    NSArray* oldBoxes = _boxes;
    
    _boxes = [boxes sortedArrayUsingComparator:^NSComparisonResult(PostBox* obj1, PostBox* obj2) {
        BOOL c1 = [obj1 hasClearanceScheduledForToday];
        BOOL c2 = [obj2 hasClearanceScheduledForToday];
        if (c1 && !c2) return NSOrderedAscending;
        if (!c1 && c2) return NSOrderedDescending;
        
        return [@([obj1 distanceFromUserLocation]) compare:@([obj2 distanceFromUserLocation])];
    }];
    
    if ([self.viewDeckController leftControllerIsOpen]) {
        [self.tableView reloadData];
        return;
    }
    
    NSArray* deleted = nil;
    NSArray* inserted = nil;
    NSMutableArray* moved = nil;

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

        moved = [NSMutableArray array];
        uint oldIndex = 0;
        for (PostBox* ob in oldBoxes) {
            uint newIndex = [_boxes index:^BOOL(PostBox* nb) {
                return [ob.id isEqualToString:nb.id];
            }];
            
            if (newIndex != NSNotFound)
                [moved addObject:@[[NSIndexPath indexPathForRow:oldIndex inSection:0], [NSIndexPath indexPathForRow:newIndex inSection:0]]];
            oldIndex++;
        }
    }
    
    [self.tableView beginUpdates];
    if (!IsEmpty(deleted)) [self.tableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationTop];
    if (!IsEmpty(inserted)) [self.tableView insertRowsAtIndexPaths:inserted withRowAnimation:UITableViewRowAnimationBottom];
    if (!IsEmpty(moved)) {
        for (NSArray* move in moved) {
            [self.tableView moveRowAtIndexPath:move[0] toIndexPath:move[1]];
            [(PostBoxCell*)[self.tableView cellForRowAtIndexPath:move[1]] configure:_boxes[[move[1] row]]];
        }
    }
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self.boxSelectionDelegate showBoxDetails:_boxes[indexPath.row] from:nil];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.boxSelectionDelegate selectBox:_boxes[indexPath.row]];
}



@end
