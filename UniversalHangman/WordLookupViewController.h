//
//  WordLookupViewController.h
//  Hangman
//
//  Created by LIANGJUN JIANG on 10/6/12.
//
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@protocol WordLookupViewControllerDelegate;
@interface WordLookupViewController : TrackedUIViewController

@property (nonatomic, assign) id <WordLookupViewControllerDelegate> delegate;
- (id)initWithWord:(NSString *)mWord;
@end

@protocol WordLookupViewControllerDelegate
- (void)wordLookupViewControllerDidFinish:(WordLookupViewController *)controller;
@end