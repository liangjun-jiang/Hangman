//
//  LJViewController.m
//  UniversalHangman
//
//  Created by LIANGJUN JIANG on 11/11/12.
//  Copyright (c) 2012 LJApps. All rights reserved.
//

#import "LJViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <iAd/iAd.h>
#import "GameKitHelper.h"
@interface LJViewController ()<ADBannerViewDelegate, GameKitHelperProtocol>
@property (nonatomic, retain) ADBannerView *bannerView;
@property (nonatomic, retain) UIPopoverController *settingPopover;
@end

@implementation LJViewController


@synthesize directionsLabel=_directionsLabel;
@synthesize wordLabel=_wordLabel;
@synthesize guessedLettersLabel=_guessedLettersLabel;
@synthesize remainingGuessesLabel=_remainingGuessesLabel;
@synthesize navBar=_navBar;
@synthesize equivalenceClass=_equivalenceClass;
@synthesize guessesLeft=_guessesLeft;
@synthesize numLetters=_numLetters;
@synthesize guessedLetters=_guessedLetters;
@synthesize isEvil = _isEvil;
@synthesize hintButton = _hintButton;
@synthesize bannerView = _bannerView;
@synthesize settingPopover;


// init
- (void)initDict
{
    //    NSLog(@"Enter MainViewController initDict");
    self.equivalenceClass = [[EquivalenceClass alloc] init];
    //    NSLog(@"Exit MainViewController initDict");
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    UIImage *backgroundImage = [UIImage imageNamed:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"blackboard_1920":@"blackboard"];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    
    
    //bring up the GameCenter
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    
    [self newGame];
    
    // this is actually a word lookup button
    self.hintButton.hidden = YES;
    
    
    // ads
    self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, 44.0)];
    self.bannerView.delegate = self;
}

- (IBAction)newGame
{
        
    // update the directions
    self.directionsLabel.text = NSLocalizedString(@"DIRECTION", @"Enter a letter to guess the word");
    self.directionsLabel.textColor = [UIColor whiteColor];
    self.wordLabel.textColor = [UIColor whiteColor];
    
    // get num of letters in word and num guesses remaining from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.guessesLeft = [[defaults objectForKey:@"numGuesses"] intValue];
    self.numLetters = [[defaults objectForKey:@"numLetters"] intValue];
    self.isEvil = [defaults boolForKey:@"isEvil"];
    
    self.navBar.topItem.title = (self.isEvil)?@"Evil Hangman":@"Hangman";
    
    self.equivalenceClass = [[EquivalenceClass alloc] init];
    self.equivalenceClass.evil = self.isEvil;
    // reset the possible words
    //    [self.equivalenceClass setEvil:self.isEvil];
    [self.equivalenceClass resetWords:self.numLetters];
    
    // create a new guessed letters
    self.guessedLetters = [[NSMutableArray alloc] initWithCapacity:26];
    
    // make the guessed letters line-breaking and word-wrapping
    self.guessedLettersLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.guessedLettersLabel.numberOfLines = 0;
    
    // got this from iOS_Hangman_Profiling movie
    // set the word with number of letters given in user preferences
    NSMutableString *blanks = [NSMutableString stringWithCapacity:self.numLetters];
    for (int i = 0; i < self.numLetters; i++) {
        [blanks appendString: @"-"];
    }
    self.wordLabel.text = blanks;
    
    [self updateGuessedLettersAndCount];
    
    self.hintButton.hidden = YES;
    self.hintButton.highlighted = NO;
    
    [self enableButtons:YES];
    
}

//Letter button pressed
- (IBAction)buttonPressed:(id)sender {
    UIButton *letterButton = (UIButton *)sender;
    [letterButton setHighlighted:YES]; // no real effect
    [letterButton setEnabled:NO];
    [letterButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateDisabled];
    NSString *guessedLetter = letterButton.titleLabel.text;
    
    unichar firstLetter = [[guessedLetter capitalizedString] characterAtIndex: 0];
    if ((firstLetter >= 'A') && (firstLetter <= 'Z'))
    {
        // if it's already been guessed
        int found = [self findLetter:guessedLetter];
        if (found == NO)
        {
            // add this letter to the guessed letters list
            [self.guessedLetters addObject:guessedLetter];
            //            NSLog(@"Guessed letters count is: %i", self.guessedLetters.count);
            
            // make a guess to find out what the biggest equivalence class is
            NSString *word;
            
            if (self.isEvil){
                word = [self.equivalenceClass guess:guessedLetter];
            }
            else {
                word = [self.equivalenceClass guess:guessedLetter withGuessed:self.wordLabel.text];
            }
            
            // subtract the number of guesses left if the guess is incorrect
            if (self.equivalenceClass.correctGuess == NO)
            {
                self.guessesLeft = self.guessesLeft - 1;
                //                NSLog(@"MainViewController: INCORRECT guess %@. Number of guesses: %d",guessedLetter, self.guessesLeft);
                
            } else
            {
                //                NSLog(@"MainViewController: CORRECT guess %@. Number of guesses: %d",guessedLetter, self.guessesLeft);
            }
            
            // update the word on the screen
            self.wordLabel.text = word;
            
            // update the UI based on the results
            [self updateGuessedLettersAndCount];
            
            // check if we lost or won the game
            [self checkResult];
        }
        
    }
    else
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle: nil
                                                        message: NSLocalizedString(@"INVALIDINPUT", @"Please enter a letter a-z or A-Z")
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"OK","Ok")
                                              otherButtonTitles: nil];
        [error show];
    }
    
}


// this is based on code from Section.zip
// example of method returning an int
- (int) findLetter:(NSString *)letterToCheck
{
    
    //    NSLog (@"Input %@", letterToCheck);
    
    int a = NO;
    
    //NSLog(@"Count in guessedLetters %i", self.guessedLetters.count);
    
    for (NSString * item in self.guessedLetters) {
        
        if ([item isEqualToString:letterToCheck]) {
            a = YES;
            //NSLog (@"Checking %@", item);
            break;
        }
    }
    
    return a;
}

// update the display of number of guesses and letters guessed
- (void) updateGuessedLettersAndCount
{
    NSMutableString *guessedString = [[NSMutableString alloc] initWithCapacity:52];
    for (NSString * item in self.guessedLetters) {
        [guessedString appendString:item];
        [guessedString appendString:@" "];
    }
    
    self.guessedLettersLabel.text = [NSString stringWithFormat:@"%@: %@",
                                     NSLocalizedString(@"LETTERS_GUESSED", @"Letters guessed"),
                                     guessedString];
    
    self.remainingGuessesLabel.text = [NSString stringWithFormat:@"%@: %i",
                                       NSLocalizedString(@"GUESSES_LEFT", @"Number of guesses left"),
                                       self.guessesLeft];
    
}

- (void)checkResult
{
    BOOL unguessed = NO;
    // if the word does not contain any dashes, user guessed the word and won
    int len = self.wordLabel.text.length;
    for (int i=0; i<len; i++)
    {
        if ([self.wordLabel.text characterAtIndex:i] == '-')
        {
            unguessed = YES;
            break;
        }
    }
    
    if (unguessed == NO)
    {
        [self win];
    }
    else if (self.guessesLeft == 0)
    {
        // if there are no more guesses left, user lost
        [self lose];
    }
}

// method to perform when the user guesses the word correctly
- (void)win
{
    
    // update the directions
    self.directionsLabel.text = NSLocalizedString(@"WIN", @"You win!!!");
    self.directionsLabel.textColor = [UIColor orangeColor];
    // We also need to disable those buttons
    [self enableButtons:NO];
    
    // show the word meaning
    self.hintButton.hidden = NO;
    self.hintButton.highlighted = YES;
    
    // post to game center
    [self postToGameCenter];
}

// method to perform when the user runs out of guesses
- (void)lose
{
    // update the directions
    self.directionsLabel.text = NSLocalizedString(@"LOSE", @"The correct word is");
    
    // update the word
    if (self.isEvil) {
        self.wordLabel.text = self.equivalenceClass.getTheWord;
    } else
        self.wordLabel.text = self.equivalenceClass.word;
    
    self.wordLabel.textColor = [UIColor redColor];
    // let the user learn the word
    self.hintButton.hidden = NO;
    self.hintButton.highlighted = YES;
    
    [self enableButtons:NO];
    
}

#pragma mark - Delegate methods

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.settingPopover dismissPopoverAnimated:YES];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self dismissModalViewControllerAnimated:YES];
    }
    // We need to refresh the screen
    [self newGame];
}

//- (void)gameCenterViewControllerDidFinish:(GameCenterController *)controller {
//    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self.settingPopover dismissPopoverAnimated:YES];
//    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        [self dismissModalViewControllerAnimated:YES];
//    }
//    
//}

- (void)wordLookupViewControllerDidFinish:(WordLookupViewController *)controller
{
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.settingPopover dismissPopoverAnimated:YES];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self dismissModalViewControllerAnimated:YES];
    }
    
}

- (IBAction)showInfo:(id)sender
{
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.settingPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        //        self.settingPopover.popoverContentSize=CGSizeMake(320.0, 460.0);
        [self.settingPopover presentPopoverFromBarButtonItem:sender  permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}


- (IBAction)showHint:(id)sender
{
    WordLookupViewController *wlvc = [[WordLookupViewController alloc] initWithWord:self.wordLabel.text];
    wlvc.delegate = self;
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.settingPopover = [[UIPopoverController alloc] initWithContentViewController:wlvc];
        [self.settingPopover presentPopoverFromRect:self.hintButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
        //        self.settingPopover.popoverContentSize=CGSizeMake(320.0, 460.0);
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        wlvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:wlvc animated:YES completion:nil];
       
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //    NSLog(@"MainViewController viewDidUnload");
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#define kEasyLeaderboardID @"Leaderboard"

- (IBAction)postToGameCenter:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    float score = [[defaults objectForKey:@"numLetters"] floatValue] / [[defaults objectForKey:@"numGuesses"] floatValue] ;
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    gameKitHelper.delegate = self;
    [gameKitHelper submitScore:score category:kEasyLeaderboardID];
    
}




- (void)postToGameCenter{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    float score = [[defaults objectForKey:@"numLetters"] floatValue] / [[defaults objectForKey:@"numGuesses"] floatValue] ;
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    gameKitHelper.delegate = self;
    [gameKitHelper submitScore:score category:kEasyLeaderboardID];
    
    //    [[GameKitHelper sharedGameKitHelper] submitScore:(int64_t)score category:kEasyLeaderboardID];
    
    //    self.gameCenterController = [[GameCenterController alloc] initWithScore:(int)(self.isEvil)?10000*score:100*score];
    //    self.gameCenterController.delegate = self;
    //    self.gameCenterController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [self presentModalViewController:self.gameCenterController animated:YES];
    
}

-(void) onScoresSubmitted:(bool)success
{
    if (success) {
        //        NSLog(@"score submitted!");
        if([GKLocalPlayer localPlayer].authenticated) {
            NSArray *arr = [[NSArray alloc] initWithObjects:[GKLocalPlayer localPlayer].playerID, nil];
            GKLeaderboard *board = [[GKLeaderboard alloc] initWithPlayerIDs:arr];
            if(board != nil) {
                board.timeScope = GKLeaderboardTimeScopeAllTime;
                board.range = NSMakeRange(1, 1);
                board.category = kEasyLeaderboardID;
                
                [board loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
                    NSString *message = @"";
                    if (error != nil) {
                        // handle the error.
                        message = @"Error retrieving score.";
                    } else if (scores != nil) {
                        NSLog(@"My Score: %lli", ((GKScore*)[scores objectAtIndex:0]).value);
                        //                        NSLog(@"the gk score: %@",(GKScore *)scores);
                        GKScore *score = [scores objectAtIndex:0];
                        NSString *highestScore = [NSString stringWithFormat:@"%lli", score.value];
                        NSString *rank =[NSString stringWithFormat:@"%d", score.rank];
                        
                        message = [NSString stringWithFormat:@"Your highest score is: %@, rank: %@",highestScore, rank];
                    } else {
                        
                        message = @"Unable to show the scoreboard.";
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scoreboard Info" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                    
                }];
                
            }
        }
        
        //    self.gameCenterController = [[GameCenterController alloc] initWithScore:(int)(self.isEvil)?10000*score:100*score];
        //        self.gameCenterController = [[GameCenterController alloc] initWithNibName:nil bundle:nil];
        //        self.gameCenterController.delegate = self;
        //        self.gameCenterController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //        [self presentModalViewController:self.gameCenterController animated:YES];
    } else
        NSLog(@"Oops");
}


#pragma private method

- (void)enableButtons:(BOOL)enabled
{
    for (int i = 50; i<= 75; i++){
        UIButton *letterButton = (UIButton *)[self.view viewWithTag:i];
        if (letterButton.enabled!=enabled) {
            letterButton.enabled = enabled;
        }
        
        if (enabled) {
            [letterButton setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
    
}


#pragma mark banner ad
// banner view delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //    [self layoutAnimated:YES];
    [self.view addSubview:self.bannerView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}

@end
