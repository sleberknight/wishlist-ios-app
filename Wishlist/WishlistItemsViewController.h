//
//  WishlistItemsViewController.h
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WishlistItemsViewController : UITableViewController
{
    IBOutlet UIView *headerView;
}

-(UIView *)headerView;
-(IBAction)addNewItem:(id)sender;
-(IBAction)toggleEditingMode:(id)sender;

@end
