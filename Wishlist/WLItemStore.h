//
//  WLItemStore.h
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLItem.h"

@interface WLItemStore : NSObject

+(WLItemStore *)defaultStore;

-(NSArray *)allItems;
-(WLItem *)createItem;

@end
