//
//  WLImageStore.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLImageStore.h"

@interface WLImageStore()

@property NSMutableDictionary *dictionary;

@end

@implementation WLImageStore

+(WLImageStore *)defaultStore {
    static WLImageStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[WLImageStore alloc] init];
    });

    return defaultStore;
}

-(id)init {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setImage:(UIImage *)img forKey:(NSString *)key {
    [_dictionary setObject:img forKey:key];
}

-(UIImage *)imageForKey:(NSString *)key {
    return [_dictionary objectForKey:key];
}

-(void)deleteImageForKey:(NSString *)key {
    if (!key) {
        return;
    }
    [_dictionary removeObjectForKey:key];
}

@end
