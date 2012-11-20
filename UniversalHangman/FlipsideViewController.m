//
//  FlipsideViewController.m
//  Hangman
//
//  Created by Janet Liu on 8/4/11.
//  Harvard Summer School 2011
//  CS S-76 Building Mobile Applications
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate=_delegate;
@synthesize lettersLabel=_lettersLabel;
@synthesize guessesLabel=_guessesLabel;
@synthesize lettersSlider=_lettersSlider;
@synthesize guessesSlider=_guessesSlider;
@synthesize navBar=_navBar;
@synthesize evilSwitch = _evilSwitch;
@synthesize instructionLabel = _instructionLabel;

static int MIN_NUM_GUESSES = 1;
static int MAX_NUM_GUESSES = 26;
static int MIN_NUM_LETTERS = 1;
static int MAX_NUM_LETTERS = 26;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.topItem.title = NSLocalizedString(@"HANGMANSETTINGS", @"Settings");
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"blackboard"]];
    
//    CGSize size = CGSizeMake(320.0,460.0);
//    self.contentSizeForViewInPopover = size;
    
    
    // set the slider min and max values
    self.guessesSlider.minimumValue = MIN_NUM_GUESSES;
    self.guessesSlider.maximumValue = MAX_NUM_GUESSES;
    
    self.lettersSlider.minimumValue = MIN_NUM_LETTERS;
    self.lettersSlider.maximumValue = MAX_NUM_LETTERS;
    
    // try to set the min and max length of words if no such words exist at the edges
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int minLetters = [[defaults objectForKey:@"minLetters"] intValue];
    int maxLetters = [[defaults objectForKey:@"maxLetters"] intValue];
    BOOL isEvil = [defaults boolForKey:@"isEvil"];
    
    [self.evilSwitch setOn:(isEvil)?YES:NO];
    
    if (minLetters != 0)
    {
        self.lettersSlider.minimumValue = minLetters;
    }
    
    if (maxLetters != 0)
    {
        self.lettersSlider.maximumValue = maxLetters;
    }

    
    // get user defaults
    int numGuesses = [[defaults objectForKey:@"numGuesses"] intValue];
    int numLetters = [[defaults objectForKey:@"numLetters"] intValue];
    
    // update the UI with the loaded defaults
    self.guessesSlider.value = numGuesses;
    self.lettersSlider.value = numLetters;
    
    
    self.guessesLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"NUMBER_GUESSES", @"Number of guesses"), numGuesses];
    self.lettersLabel.text =[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"NUMBER_LETTERS", @"Number of letters"), numLetters];
    
    self.instructionLabel.text = [NSString stringWithFormat:@"You can earn %.0f points for normal Hangman Game. And you will earn 100 times (%.0f) for Evil Hangman Game.", 100*(float)numLetters / numGuesses, 10000*(float)numLetters / numGuesses];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    // check that the number of guesses is not smaller than the number of letters
    int numLetters = self.lettersSlider.value;
    int numGuesses = self.guessesSlider.value;
    if (numGuesses < numLetters)
    {  
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle: nil 
                                                      message: NSLocalizedString(@"MIN_GUESSES",
                                                                                 @"The number of guesses must be at least the number of letters.")
                                                     delegate: self 
                                            cancelButtonTitle: NSLocalizedString(@"OK", @"ok")  
                                            otherButtonTitles: nil];
        [msg show];
        [msg release];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check that the selected length has a valid word
    NSNumber *numWords = [defaults objectForKey:@"numLetters"];
    if ((numWords == nil) || ([numWords intValue] == 0))
    {
        // do not allow this   
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle: nil 
                                                      message: NSLocalizedString(@"NO_LENGTH",
                                                                                 @"There are no words with the given length. Please pick another length.")
                                                     delegate: self 
                                            cancelButtonTitle: NSLocalizedString(@"OK", @"ok") 
                                            otherButtonTitles: nil];
        [msg show];
        [msg release];        return;
    }
        
    // save settings
    [defaults setObject:[NSNumber numberWithInt:self.lettersSlider.value] forKey:@"numLetters"];
    [defaults setObject:[NSNumber numberWithInt:self.guessesSlider.value] forKey:@"numGuesses"];
    [defaults synchronize];
    
    [self.delegate flipsideViewControllerDidFinish:self];

}

// called when the slider for num letters changed. update the corresponding label.
- (IBAction)numLettersChanged:(id)sender
{
    UISlider *lettersSlider = (UISlider *)sender;
    int n = (int)lettersSlider.value;
    self.lettersLabel.text = [NSString stringWithFormat:@"%@: %d",
                              NSLocalizedString(@"NUMBER_LETTERS", @"Number of letters"), 
                              n];
    
    self.instructionLabel.text = [NSString stringWithFormat:@"You can earn %.0f points for normal Hangman Game. And you will earn 100 times (%.0f) for Evil Hangman Game.", 100*n / self.guessesSlider.value, 10000*n / self.guessesSlider.value];
    
    
}

// called when the slider for num guesses changed. update the corresponding label.
- (IBAction)numGuessesChanged:(id)sender
{
    UISlider *guessesSlider = (UISlider *)sender;
    int n = (int)guessesSlider.value;
    self.guessesLabel.text = [NSString stringWithFormat:@"%@: %d",
                              NSLocalizedString(@"NUMBER_GUESSES", @"Number of guesses"),
                              n];
    
    self.instructionLabel.text = [NSString stringWithFormat:@"You can earn %.0f points for normal Hangman Game. And you will earn 100 times (%.0f) for Evil Hangman Game.", 100*self.lettersSlider.value / n, 10000*self.lettersSlider.value / n];
    
}

- (IBAction)gameTypeChanged:(id)sender{
    
    UISwitch *evilSwitch = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:(evilSwitch.on)?YES:NO forKey:@"isEvil"];

}

- (IBAction)showEvil:(id)sender {
   
    WordLookupViewController *lookup = [[WordLookupViewController alloc] initWithNibName:nil bundle:nil];
    lookup.delegate = self;
    [self presentModalViewController:lookup animated:YES];
    
}


#pragma mark - Delegate method
- (void)wordLookupViewControllerDidFinish:(WordLookupViewController *)controller
{
   [self dismissModalViewControllerAnimated:YES];
}

@end
