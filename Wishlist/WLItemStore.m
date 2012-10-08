//
//  WLItemStore.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLItemStore.h"
#import "WLItem.h"

@interface WLItemStore()

@property (nonatomic, strong) NSMutableArray *allItems;

@end

@implementation WLItemStore

+(WLItemStore *)defaultStore {
    static WLItemStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[WLItemStore alloc] init];
    });

    return defaultStore;
}

-(id)init {
    self = [super init];
    if (self) {
        _allItems = [[NSMutableArray alloc] init];
    }
    return self;
}

-(WLItem *)createItem {
    WLItem *item = [WLItem randomItem];

    [_allItems addObject:item];

    return item;
}

-(void)removeItem:(WLItem *)item {
    [_allItems removeObjectIdenticalTo:item];
}

@end
