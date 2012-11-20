//
//  LJAppDelegate.m
//  UniversalHangman
//
//  Created by LIANGJUN JIANG on 11/11/12.
//  Copyright (c) 2012 LJApps. All rights reserved.
//

#import "LJAppDelegate.h"

#import "LJViewController.h"

@implementation LJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self customApperance];
    // from Tom Barrasso on help bulletin board
    // Fetch preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Set defaults of preferences
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:
                                [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[LJViewController alloc] initWithNibName:@"MainView" bundle:nil];
    } else {
        self.viewController = [[LJViewController alloc] initWithNibName:@"MainView_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private method
- (void)customApperance {
    // Create image for navigation background - portrait
    UIImage *navBarBackground = [UIImage imageNamed:@"navigationBar"];
    // Set the background image all UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:navBarBackground
                                       forBarMetrics:UIBarMetricsDefault];
    
    // Set the text appearance for navbar
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIColor redColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"ChalkboardSE-Bold" size:19], UITextAttributeFont,
      nil]];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor lightGrayColor]];
    
    
}

@end
