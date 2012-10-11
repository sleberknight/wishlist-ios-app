//
//  WLItem.h
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLItem : NSObject <NSCoding>

+(id)randomItem;

-(id)initWithItemName:(NSString *)name;

-(id)initWithItemName:(NSString *)name
             occasion:(NSString *)occasion
                store:(NSString *)store
                price:(int)price;

@property (nonatomic, strong) WLItem *containedItem;
@property (nonatomic, weak) WLItem *container;

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *occasion;
@property (nonatomic, copy) NSString *store;
@property (nonatomic, assign) int price;
@property (nonatomic, copy) NSString *imageKey;
@property (readonly, nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateModified;

@end
