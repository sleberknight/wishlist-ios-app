//
//  WLItemStore.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLItemStore.h"
#import "WLItem.h"
#import "WLImageStore.h"

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
        NSString *path = [self itemArchivePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"Loading items from existing archive %@", path);

            _allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

            if (!_allItems) {
                NSLog(@"Error unarchiving items from archive %@", path);
            }
        }

        if (!_allItems) {
            NSLog(@"Initializing empty items array");
            _allItems = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

-(NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

-(BOOL)saveChanges {
    NSString *path = [self itemArchivePath];
    NSData *archivedItems = [NSKeyedArchiver archivedDataWithRootObject:_allItems];
    NSError * error;
    [archivedItems writeToFile:path options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"Error saving %d items to path %@: %@, %@, %@",
              [_allItems count],
              path,
              [error localizedDescription],
              [error localizedFailureReason],
              [error localizedRecoverySuggestion]);
        return NO;
    }

    NSLog(@"Saved %d items successfully to path %@", [_allItems count], path);
    return YES;
}

-(WLItem *)createItem {
    WLItem *item = [[WLItem alloc] initWithItemName:@""];

    [_allItems addObject:item];

    return item;
}

-(void)removeItem:(WLItem *)item {
    NSString *imageKey = [item imageKey];
    [[WLImageStore defaultStore] deleteImageForKey:imageKey];

    [_allItems removeObjectIdenticalTo:item];
}

-(void)moveItemAtIndex:(int)from toIndex:(int)to {
    if (from == to) {
        return;
    }

    WLItem *itemBeingMoved = [_allItems objectAtIndex:from];

    // Remove item from array
    [_allItems removeObjectAtIndex:from];

    // Insert item into new position
    [_allItems insertObject:itemBeingMoved atIndex:to];
}

@end
