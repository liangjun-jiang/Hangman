//
//  LJViewController.h
//  UniversalHangman
//
//  Created by LIANGJUN JIANG on 11/11/12.
//  Copyright (c) 2012 LJApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlipsideViewController.h"
#import "EquivalenceClass.h"
#import "EasyTracker.h"

#import "WordLookupViewController.h"

@interface LJViewController : TrackedUIViewController <FlipsideViewControllerDelegate,  WordLookupViewControllerDelegate>
@property (nonatomic, retain) IBOutlet UIButton *hintButton;

@property (nonatomic, retain) IBOutlet UILabel *directionsLabel;
@property (nonatomic, retain) IBOutlet UILabel *wordLabel;
@property (nonatomic, retain) IBOutlet UILabel *guessedLettersLabel;
@property (nonatomic, retain) IBOutlet UILabel *remainingGuessesLabel;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) EquivalenceClass *equivalenceClass;
@property (nonatomic, assign) int guessesLeft;
@property (nonatomic, assign) int numLetters;
@property (nonatomic, assign) BOOL isEvil;

@property (nonatomic, retain) NSMutableArray *guessedLetters;

- (IBAction)showInfo:(id)sender;
- (IBAction)newGame;
- (void)win;
- (void)lose;
- (int)findLetter:(NSString *)letterToCheck;
- (void)updateGuessedLettersAndCount;
- (void)initDict;
- (void)checkResult;
- (IBAction)postToGameCenter:(id)sender;
@end
