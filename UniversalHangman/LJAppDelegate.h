//
//  LJAppDelegate.h
//  UniversalHangman
//
//  Created by LIANGJUN JIANG on 11/11/12.
//  Copyright (c) 2012 LJApps. All rights reserved.
//  Some codes are from Apple Sample code: GKLeaderboards

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

// Preferred method for testing for Game Center
static BOOL isGameCenterAPIAvailable();

@class LJViewController;

@interface LJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LJViewController *viewController;

// currentPlayerID is the value of the playerID last time we authenticated.
@property (retain,readwrite) NSString * currentPlayerID;

// isGameCenterAuthenticationComplete is set after authentication, and authenticateWithCompletionHandler's completionHandler block has been run. It is unset when the application is backgrounded.
@property (readwrite, getter=isGameCenterAuthenticationComplete) BOOL gameCenterAuthenticationComplete;

@end
