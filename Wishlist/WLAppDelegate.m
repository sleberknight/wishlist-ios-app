//
//  WLAppDelegate.m
//  Wishlist
//
//  Created by Scott Leberknight on 10/8/12.
//  Copyright (c) 2012 Scott Leberknight. All rights reserved.
//

#import "WLAppDelegate.h"
#import "WLItemsViewController.h"
#import "WLItem.h"
#import "WLItemStore.h"

@implementation WLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    WLItemsViewController *itemsViewController = [[WLItemsViewController alloc] init];

    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:itemsViewController];
    self.window.rootViewController = navController;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    BOOL success = [[WLItemStore defaultStore] saveChanges];
    if (success) {
        NSLog(@"Items saved successfully");
    }
    else {
        NSLog(@"Error saving the items.ß");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
