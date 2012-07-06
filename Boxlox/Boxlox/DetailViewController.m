//
//  DetailViewController.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 05/07/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "DetailViewController.h"
#import "PostBox.h"
#import "UITableViewCell+AutoDequeue.h"
#import "ClearanceCell.h"
#import "ButtonCell.h"

@interface DetailViewController ()

@end

@implementation DetailViewController {
    PostBox* _postbox;
}

- (CGSize)contentSizeForViewInPopover {
    return (CGSize) { 400, 400 };
}

- (id)initWithPostBox:(PostBox*)postbox
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _postbox = postbox;
    }
    return self;
}

// doing it like this for now due to a bug in 4.5
- (void)loadView {
    self.tableView = [[UITableView alloc] initWithFrame:(CGRect) { 0, 0, 400, 400 } style:UITableViewStyleGrouped];
    self.view = self.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Details";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[BoxLox boxLocator] canLocateUser] ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _postbox.addressNL.count;
        case 1:
            return !IsEmpty(_postbox.clearance) + !IsEmpty(_postbox.clearanceSaturday);
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Location";
        case 1:
            return @"Last Clearance";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if (indexPath.section >= 2)
        return 38;
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            UITableViewCell* cell = [UITableViewCell tableViewAutoDequeueCell:self.tableView];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = _postbox.addressNL[indexPath.row];
            return cell;
        }
            
        case 1: {
            ClearanceCell* cell = [ClearanceCell tableViewAutoDequeueCell:self.tableView];
            [cell configure:_postbox asSaturday:indexPath.row > 0];
            return cell;
        }

        case 2: {
            ButtonCell* cell = [ButtonCell tableViewAutoDequeueCell:self.tableView];
            [cell configureWithText:@"Open in Maps" action:^{
                NSString* url = [NSString stringWithFormat:@"maps://maps?dummy=1&ll=%f,%f&q=%@", _postbox.location.coordinate.latitude, _postbox.location.coordinate.longitude, [_postbox.fullAddressNL stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }];
            return cell;
        }

        case 3: {
            ButtonCell* cell = [ButtonCell tableViewAutoDequeueCell:self.tableView];
            [cell configureWithText:@"Get Directions" action:^{
                CLLocation* ul = [[BoxLox boxLocator] userLocation];
                NSString* url = [NSString stringWithFormat:@"maps://maps?dummy=1&saddr=%f,%f&daddr=%f,%f&dirflg=%@", ul.coordinate.latitude, ul.coordinate.longitude, _postbox.location.coordinate.latitude, _postbox.location.coordinate.longitude, [_postbox distanceFromUserLocation] > 500 ? @"h" : @"w"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }];
            return cell;
        }

        default:
            return nil;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
