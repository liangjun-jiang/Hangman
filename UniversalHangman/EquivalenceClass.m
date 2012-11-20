//
//  EquivalenceClass.m
//  Hangman
//
//  Created by Janet Liu on 8/5/11.
//  Harvard Summer School 2011
//  CS S-76 Building Mobile Applications
//

#import "EquivalenceClass.h"
#import <stdio.h>

@implementation EquivalenceClass

@synthesize wordsByLengthDictionary=_wordsByLengthDictionary;
@synthesize words=_words;
@synthesize word=_word;
@synthesize minLetters=_minLetters;
@synthesize maxLetters=_maxLetters;
@synthesize numLetters=_numLetters;
@synthesize correctGuess=_correctGuess;
@synthesize evil= _evil;
//@synthesize selectedWord = _selectedWord;

// initialize and parse the words
- (id)init
{
//    NSLog(@"EquivalenceClass init");
    self = [super init];
    
    if (self) {
        self.wordsByLengthDictionary = [NSMutableDictionary dictionary];
        self.words = nil;
        self.word = nil;
        
        self.evil = NO;
        
        [self parseByLength];
    }
    
    return self;
}


// parse words file and put into a dictionary by length
- (void)parseByLength
{
    if (self.wordsByLengthDictionary == nil) {
        NSLog(@"The dictionary is nil!");
    }

    // set this to values that will be changed
    self.minLetters = 27;
    self.maxLetters = 0;

    // from iOS_Hangman_Profiling.mp4
    // load words.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"plist"];
    NSArray *tmp = [NSArray arrayWithContentsOfFile:path];
//    NSLog(@"Number of items in the words.plist %i", tmp.count);
    
    for (NSString * item in tmp)
    {
        NSNumber *wordLength = [NSNumber numberWithInteger:item.length];
        NSMutableArray *tmpArray = [self.wordsByLengthDictionary objectForKey:wordLength];
        if (tmpArray == nil)
        {
            // create the array
            tmpArray = [NSMutableArray arrayWithCapacity:30];
            
            // set the minimum and maximum possible word lengths
            if (item.length < self.minLetters)
            {
                self.minLetters = item.length;
            } else if (item.length > self.maxLetters)
            {
                self.maxLetters = item.length;
            }
            
            // add the array to the dictionary
            [self.wordsByLengthDictionary setObject:tmpArray forKey:wordLength];
        }
        
        // add the word to the array of words with this given length
        [tmpArray addObject:item];
    }
    
    [self saveMinMaxLettersToDefaults];
//    NSLog(@"Minimum word length: %d, maximum word length: %d", self.minLetters, self.maxLetters);
    
//    for (int i=1; i<27; i++)
//    {
//        NSNumber *wordLength = [NSNumber numberWithInteger:i];
//        NSMutableArray *tmpArray = [self.wordsByLengthDictionary objectForKey:wordLength];
//        NSLog(@"Number of words with length %d: %d", i, tmpArray.count);
//    }
    
}

// save the minLetters and maxLetters to the defaults
- (void)saveMinMaxLettersToDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // save settings
    [defaults setObject:[NSNumber numberWithInt:self.minLetters] forKey:@"minLetters"];
    [defaults setObject:[NSNumber numberWithInt:self.maxLetters] forKey:@"maxLetters"];
    [defaults synchronize];
}

// reset the words list based on the number of letters
- (void)resetWords:(int)numLetters
{
    self.word = nil;
    
    self.words = [self.wordsByLengthDictionary objectForKey:[NSNumber numberWithInteger:numLetters]];
//    NSLog(@"EquivalenceClass resetWords with length %d: There are %d words.", numLetters, self.words.count);
    
    self.numLetters = numLetters;
    
    if (!self.evil) {
        self.word = [self getTheWord];
    }

}

// given the length of words, and a letter guess, create the equivalence classes
// and set the largest equivalence class.
// sets the property self.words with the biggest equivalence class
// returns the word after the guess
- (NSString *)guess:(NSString *) letter
{
//    NSLog(@"Guess letter %@, Number of words in list: %i", letter, self.words.count);
    
    // create a dictionary using the equivalence class with the letter inserted (or all blanks) as the key
    // and an array of words that fall into this equivalence class as the value
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // keep track of the size of largest equivalence class
    int largest = 0;
    
    // keep track of an array of the keys of the largest equivalence classes
    NSMutableArray *largestKeysArray = nil;
    
    letter = [letter capitalizedString];
    char guess = [letter characterAtIndex:0];
    
    for (NSString * item in self.words)
    {
        NSMutableString *key = [NSMutableString stringWithCapacity:self.numLetters];
        for (int i=0; i<item.length; i++)
        {
            // create the key composed of "-" or the guessed character
            // with any existing characters that are already filled in
            char c = [item characterAtIndex:i];
            if (c == guess)
            {
                [key appendString:[NSString stringWithFormat:@"%c",c]];
            }
            else
            {
                if (self.word != nil)
                {
                    char d = [self.word characterAtIndex:i];
                    [key appendString:[NSString stringWithFormat:@"%c", d]];
                }
                else
                {
                    [key appendString:@"-"];
                }
            }
        }
//        NSLog(@"Key %@, Value %@", key, item);
        
        // is this equivalence class in the dictionary
        NSMutableArray *valuesArray = [dict objectForKey:key];
        if (valuesArray == nil)
        {
            valuesArray = [[NSMutableArray alloc] init];
            [valuesArray addObject:item];
            [dict setObject:valuesArray forKey:key];
            //NSLog(@"Values array count %d, created", valuesArray.count);
            [valuesArray release];
        }
        else
        {
            //NSLog(@"Values array count %d", valuesArray.count);
            [valuesArray addObject:item];
        }
        
        // store the largest equivalence class size and key
        if (valuesArray.count > largest)
        {
            // this is the new largest equivalence class size
            largest = valuesArray.count;
            
            // clear any old arrays of the largest equivalence classes, and start a new array
            if (largestKeysArray == nil)
            {
                [largestKeysArray release];
                largestKeysArray = [[NSMutableArray alloc] init];
            }
            [largestKeysArray addObject:key];
        }
        else if (valuesArray.count == largest)
        {
            // add to the existing array of largest equivalence classes
            [largestKeysArray addObject:key];
        }
    }
    
    // keep track of the key of the largest equivalence class
    NSString *largestKey = nil;
    // pick a random one from the largest equivalence classes array
    // arc4random get a random word between 0 and largestKeysArray-1
    int randomIndex = arc4random() % largestKeysArray.count;
//    NSLog(@"Index %d out of 0 to %d",randomIndex, (largestKeysArray.count-1));
    largestKey = [largestKeysArray objectAtIndex:randomIndex];
    
    // don't need this anymore
    [largestKeysArray release];
    
    // find out the largest equivalence class
//    NSLog(@"The largest equivalence class is %@, with %d words", largestKey, largest);
    
    // need to determine whether this is a correct guess
    if ([largestKey rangeOfString:letter].location != NSNotFound)
    {
//        NSLog(@"Correct Guess: %@ is in %@",letter,largestKey);
        self.correctGuess = YES;
    }
    else
    {
//        NSLog(@"INCORRECT Guess: %@ is NOT in %@",letter,largestKey);
        self.correctGuess = NO;
    }
    
    self.words = [dict objectForKey:largestKey];
    
    // done with the other words
    [dict release];
    
    self.word = largestKey;
    
    return self.word;
    
}

// get a random word from the remaining words
- (NSString *)getTheWord
{
    // arc4random get a random word between 0 and count-1
    int randomIndex = arc4random() % self.words.count;
    //NSLog(@"Index %d out of %d",randomIndex, (self.words.count-1));
    return [self.words objectAtIndex:randomIndex];
}


// We use this to handle the standard hangman
- (NSString *)guess:(NSString *) letter withGuessed:(NSString *)guessed;
{
//    NSLog(@"Guess letter %@, Number of words in list: %i, and the word: %@", letter, self.words.count, self.word);
    
    // Standard Hangman
    if ([self.word rangeOfString:letter].location != NSNotFound){
        self.correctGuess = YES;
        NSMutableString *key = [NSMutableString stringWithString:guessed];
        
        // we can also do it in a for loop
        char guessChar = [letter characterAtIndex:0];
        for (int i = 0; i<self.word.length; i++)
        {
            char c = [self.word characterAtIndex:i];
            if (guessChar == c)
            {
                [key replaceCharactersInRange:NSMakeRange(i,1) withString:letter];
            }
        }
        
        return key;
    } else {
        self.correctGuess = NO;
        return guessed;
    }
    
}

- (void)dealloc
{
    [self.words release];
    [self.wordsByLengthDictionary release];
    [super dealloc];
}

@end
