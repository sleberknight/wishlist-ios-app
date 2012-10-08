//
//  WishlistItemsViewController.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WishlistItemsViewController.h"
#import "WLItemStore.h"

@implementation WishlistItemsViewController

-(id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self ) {
        // Temporary to get some items
        for (int i = 0; i < 5; i++) {
            [[WLItemStore defaultStore] createItem];
        }
        NSLog(@"Created %d test items", [[[WLItemStore defaultStore] allItems] count]);
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style {
    return [self init];
}

-(UIView *)headerView {
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
    }

    return headerView;
}

-(IBAction)addNewItem:(id)sender {
    WLItem *newItem = [[WLItemStore defaultStore] createItem];

    int lastRow = [[[WLItemStore defaultStore] allItems] indexOfObject:newItem];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];

    [[self tableView] insertRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationTop];
}

-(IBAction)toggleEditingMode:(id)sender;{
    if ([self isEditing]) {
        // Turn editing mode off
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self setEditing:NO animated:YES];
    }
    else {
        // Turn editing mode on
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self setEditing:YES animated:YES];
    }
}


#pragma mark Table View Data Source methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[WLItemStore defaultStore] allItems] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Check for a reusable cell first
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];

    // If there isn't a reusable cell, then create one
    if (!cell) {
        NSLog(@"Creating new UITableViewCell");
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"UITableViewCell"];
    }

    // Set text on cell
    WLItem *item = [[[WLItemStore defaultStore] allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item description]];

    return cell;
}

#pragma mark Table View Delegate methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self headerView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // Determine height of header view from height of view in HeaderView XIB file
    return [[self headerView] bounds].size.height;
}

@end
