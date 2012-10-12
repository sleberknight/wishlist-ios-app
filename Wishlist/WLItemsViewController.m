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
#import "WLImageStore.h"

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

-(IBAction)addNewItem:(id)sender {
    WLItem *newItem = [[WLItemStore defaultStore] createItem];

    WLDetailViewController *detailViewController = [[WLDetailViewController alloc] initForNewItem:YES];
    [detailViewController setItem:newItem];
    [detailViewController setDismissBlock:^{
        [[self tableView] reloadData];
    }];

    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:detailViewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

    [self presentViewController:navController animated:YES completion:nil];
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
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:@"UITableViewCell"];
    }

    // Set text and detail text labels on cell
    WLItem *item = [[[WLItemStore defaultStore] allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item itemName]];
    NSString *details = [NSString stringWithFormat:@"%@, %@ ($%d)",
                          [item occasion],
                          [item store],
                          [item price]];
    [[cell detailTextLabel] setText:details];

    // TODO: Use thumbnail images instead of resizing the real ones for each cell!!!
    //       The thumbnails should be created in the imagePickerController:didFinishPickingMediaWithInfo:
    //       method in the WLDetailViewController and saved at that time via the WLImageStore alongside the
    //       normal images.
    //
    // Set image on cell; for now we are going to resize each one dynamically.
    // They should be stored as thumbnails separately along with the original
    // images and retrieved from the image store.
    //
    NSString *imageKey = [item imageKey];
    UIImage *originalImage = [[WLImageStore defaultStore] imageForKey:imageKey];

    // Resize the image
    CGSize cellViewSize = CGSizeMake(36.0, 36.0);
    CGRect cellViewRect = [WLImageStore rectForImage:originalImage withSize:cellViewSize];
    UIGraphicsBeginImageContext(cellViewSize);
    [originalImage drawInRect:cellViewRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();

    [[cell imageView] setImage:resizedImage];

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLDetailViewController *detailViewController = [[WLDetailViewController alloc] initForNewItem:NO];

    NSArray *items = [[WLItemStore defaultStore] allItems];
    WLItem *selectedItem = [items objectAtIndex:[indexPath row]];

    // Ensure detail view controller has a pointer to the selected item
    [detailViewController setItem:selectedItem];

    [[self navigationController] pushViewController:detailViewController animated:YES];
}

@end
