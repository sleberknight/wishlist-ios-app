//
//  WLItem.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLItem.h"

@implementation WLItem

-(id)init {
    return [self initWithItemName:@"New Item" occasion:@"" store:@"" price:0];
}

-(id)initWithItemName:(NSString *)name {
    return [self initWithItemName:name occasion:@"" store:@"" price:0];
}

-(id)initWithItemName:(NSString *)name
             occasion:(NSString *)occasion
                store:(NSString *)store
                price:(int)price {
    self = [super init];
    if (self) {
        [self setItemName:name];
        [self setOccasion:occasion];
        [self setStore:store];
        [self setPrice:price];
        _dateCreated = [[NSDate alloc] init];
        _dateModified = nil;
    }
    return self;
}

-(NSString *)description {
    NSString *desc = [[NSString alloc] initWithFormat:@"%@ for %@, at %@, price $%d, created %@, modified %@",
                      _itemName,
                      _occasion,
                      _store,
                      _price,
                      _dateCreated,
                      _dateModified];
    return desc;
}

// Override default setter to establish bi-directional relationship
-(void)setContainedItem:(WLItem *)item {
    _containedItem = item;
    [item setContainer:self];
}

+(id)randomItem {
    NSArray *colors = @[@"Red", @"Green", @"Yellow", @"Blue"];
    NSArray *things = @[@"Fire Engine", @"Police Car", @"Helicopter", @"Mac Truck"];

    NSInteger colorIndex = arc4random_uniform([colors count]);
    NSInteger thingIndex = arc4random_uniform([things count]);
    NSString *randomItemName = [NSString stringWithFormat:@"%@ %@",
                                [colors objectAtIndex:colorIndex],
                                [things objectAtIndex:thingIndex]];

    NSArray *occasions = @[@"Birthday", @"Anniversary", @"Christmas", @"Nothing specific..."];
    NSInteger occasionIndex = arc4random_uniform([occasions count]);
    NSString *randomOccasion = [occasions objectAtIndex:occasionIndex];

    NSArray *stores = @[@"Amazon", @"Target", @"Costco"];
    NSInteger storeIndex = arc4random_uniform([stores count]);
    NSString *randomStore = [stores objectAtIndex:storeIndex];

    float randomPrice = arc4random_uniform(100);

    WLItem *randomItem = [[WLItem alloc] initWithItemName:randomItemName
                                                 occasion:randomOccasion
                                                    store:randomStore
                                                    price:randomPrice];

    return randomItem;
}

#pragma mark NSCoding protocol methods

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _itemName = [aDecoder decodeObjectForKey:@"itemName"];
        _occasion = [aDecoder decodeObjectForKey:@"occasion"];
        _store = [aDecoder decodeObjectForKey:@"store"];
        _price = [aDecoder decodeIntForKey:@"price"];
        _imageKey = [aDecoder decodeObjectForKey:@"imageKey"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        _dateModified = [aDecoder decodeObjectForKey:@"dateModified"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_itemName forKey:@"itemName"];
    [aCoder encodeObject:_occasion forKey:@"occasion"];
    [aCoder encodeObject:_store forKey:@"store"];
    [aCoder encodeInt:_price forKey:@"price"];
    [aCoder encodeObject:_imageKey forKey:@"imageKey"];
    [aCoder encodeObject:_dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:_dateModified forKey:@"dateModified"];
}

@end
