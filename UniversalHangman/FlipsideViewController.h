//
//  FlipsideViewController.h
//  Hangman
//
//  Created by Janet Liu on 8/4/11.
//  Harvard Summer School 2011
//  CS S-76 Building Mobile Applications
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"
#import "WordLookupViewController.h"
@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : TrackedUIViewController<WordLookupViewControllerDelegate> {

}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UILabel *lettersLabel;
@property (nonatomic, retain) IBOutlet UILabel *guessesLabel;
@property (nonatomic, retain) IBOutlet UISlider *lettersSlider;
@property (nonatomic, retain) IBOutlet UISlider *guessesSlider;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UISwitch *evilSwitch;
@property (nonatomic, retain) IBOutlet UILabel *instructionLabel;



- (IBAction)done:(id)sender;
- (IBAction)numLettersChanged:(id)sender;
- (IBAction)numGuessesChanged:(id)sender;
- (IBAction)gameTypeChanged:(id)sender;
- (IBAction)showEvil:(id)sender;
- (IBAction)removeAds:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
