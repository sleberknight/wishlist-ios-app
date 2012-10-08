//
//  WLItemsViewController.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLItemsViewController.h"
#import "WLDetailViewController.h"
#import "WLItemStore.h"

@implementation WLItemsViewController

-(id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self ) {
        UINavigationItem *navItem = [self navigationItem];
        [navItem setTitle:@"Wishlist"];

        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                          target:self
                                          action:@selector(addNewItem:)];
        [[self navigationItem] setRightBarButtonItem:addButtonItem];

        // Calling editButtonItem sets up editing for the table view
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style {
    return [self init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove item from store
        WLItemStore *store = [WLItemStore defaultStore];
        NSArray *items = [store allItems];
        WLItem *item = [items objectAtIndex:[indexPath row]];
        [store removeItem:item];

        // Remove item from table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
     toIndexPath:(NSIndexPath *)destinationIndexPath {

    [[WLItemStore defaultStore] moveItemAtIndex:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
}

#pragma mark Table View Delegate methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self headerView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // Determine height of header view from height of view in HeaderView XIB file
    return [[self headerView] bounds].size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLDetailViewController *detailViewController = [[WLDetailViewController alloc] init];

    NSArray *items = [[WLItemStore defaultStore] allItems];
    WLItem *selectedItem = [items objectAtIndex:[indexPath row]];

    // Ensure detail view controller has a pointer to the selected item
    [detailViewController setItem:selectedItem];

    [[self navigationController] pushViewController:detailViewController animated:YES];
}

@end
