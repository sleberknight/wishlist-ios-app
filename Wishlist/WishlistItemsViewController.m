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

@end
