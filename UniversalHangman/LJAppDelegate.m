//
//  LJAppDelegate.m
//  UniversalHangman
//
//  Created by LIANGJUN JIANG on 11/11/12.
//  Copyright (c) 2012 LJApps. All rights reserved.
//

#import "LJAppDelegate.h"

#import "LJViewController.h"
#import "RageIAPHelper.h"
@implementation LJAppDelegate
@synthesize currentPlayerID, gameCenterAuthenticationComplete;

#pragma mark -
#pragma mark Game Center Support

// Check for the availability of Game Center API.
static BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    [RageIAPHelper sharedInstance];
    
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
    
    
    // Check game center
    self.gameCenterAuthenticationComplete = NO;
    
    if (!isGameCenterAPIAvailable()) {
        // Game Center is not available.
    } else {
        
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        /*
         The authenticateWithCompletionHandler method is like all completion handler methods and runs a block
         of code after completing its task. The difference with this method is that it does not release the
         completion handler after calling it. Whenever your application returns to the foreground after
         running in the background, Game Kit re-authenticates the user and calls the retained completion
         handler. This means the authenticateWithCompletionHandler: method only needs to be called once each
         time your application is launched. This is the reason the sample authenticates in the application
         delegate's application:didFinishLaunchingWithOptions: method instead of in the view controller's
         viewDidLoad method.
         
         Remember this call returns immediately, before the user is authenticated. This is because it uses
         Grand Central Dispatch to call the block asynchronously once authentication completes.
         */
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            // If there is an error, do not assume local player is not authenticated.
            if (localPlayer.isAuthenticated) {
                
                // Enable Game Center Functionality
                self.gameCenterAuthenticationComplete = YES;
                
                if (! self.currentPlayerID || ! [self.currentPlayerID isEqualToString:localPlayer.playerID]) {
                    
                    // Switching Users
                    if (!self.viewController.player || ![self.currentPlayerID isEqualToString:localPlayer.playerID]) {
                        // If there is an existing player, replace the existing PlayerModel object with a
                        // new object, and use it to load the new player's saved achievements.
                        // It is not necessary for the previous PlayerModel object to writes its data first;
                        // It automatically saves the changes whenever its list of stored
                        // achievements changes.
                        
                        self.viewController.player = [[PlayerModel alloc] init];
                    }
                    [[self.viewController player] loadStoredScores];
                    [[self.viewController player] resubmitStoredScores];
                    
                    // Load new game instance around new player being logged in.
                    
                }
                [self.viewController enableGameCenter:YES];
            } else {
                // User has logged out of Game Center or can not login to Game Center, your app should run
				// without GameCenter support or user interface.
                self.gameCenterAuthenticationComplete = NO;
                [self.viewController enableGameCenter:NO];
            }
        }];
    }
    
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
    self.gameCenterAuthenticationComplete = NO;
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
