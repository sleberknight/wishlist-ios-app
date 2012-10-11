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

        [self createImagesDirectoryIfNecessary];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

-(void)createImagesDirectoryIfNecessary {
    NSString *imagesPath = [self imagesPath];

    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagesPath isDirectory:&isDir] && isDir) {
        return;
    }

    NSLog(@"Creating images directory at %@", imagesPath);
    NSError *error;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath
                                            withIntermediateDirectories:NO
                                                             attributes:nil
                                                                  error:&error];
    if (!result) {
        NSLog(@"Error creating images directory at %@: %@, %@, %@",
              imagesPath,
              [error localizedDescription],
              [error localizedFailureReason],
              [error localizedRecoverySuggestion]);
    }
}

-(NSString *)imagesPath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"images"];
}

-(NSString *)imagePathForKey:(NSString *)key {
    return [[self imagesPath] stringByAppendingPathComponent:key];
}

-(void)setImage:(UIImage *)img forKey:(NSString *)key {
    [_dictionary setObject:img forKey:key];

    NSString *imagePath = [self imagePathForKey:key];

    CGFloat compressionQuality = 0.5;
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);

    NSError *error;
    [imageData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"Error writing image to path %@: %@, %@, %@",
              imagePath,
              [error localizedDescription],
              [error localizedFailureReason],
              [error localizedRecoverySuggestion]);
    }
}

-(UIImage *)imageForKey:(NSString *)key {
    UIImage *image = [_dictionary objectForKey:key];

    if (!image) {
        // Image not cached, so load it from file system
        NSString *imagePath = [self imagePathForKey:key];
        image = [UIImage imageWithContentsOfFile:imagePath];

        // Cache image if it successfully loaded
        if (image) {
            [_dictionary setObject:image forKey:key];
        }
        else {
            NSLog(@"Error loading image from %@", imagePath);
        }
    }

    return image;
}

-(void)deleteImageForKey:(NSString *)key {
    if (!key) {
        return;
    }
    [_dictionary removeObjectForKey:key];

    NSString *imagePath = [self imagePathForKey:key];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error];
    NSLog(@"Error removing image from path %@: %@, %@, %@",
          imagePath,
          [error localizedDescription],
          [error localizedFailureReason],
          [error localizedRecoverySuggestion]);

}

-(void)clearCache:(NSNotification *)notification {
    NSLog(@"Flushing %d images from the cache after receiving notification %@",
          [_dictionary count],
          [notification name]);
    [_dictionary removeAllObjects];
}

@end
