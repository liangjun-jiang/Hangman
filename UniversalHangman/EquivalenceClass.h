//
//  EquivalenceClass.h
//  Hangman
//
//  Created by Janet Liu on 8/5/11.
//  Harvard Summer School 2011
//  CS S-76 Building Mobile Applications
//

#import <Foundation/Foundation.h>


@interface EquivalenceClass : NSObject {
    
}

@property (nonatomic, retain) NSMutableDictionary *wordsByLengthDictionary;
@property (nonatomic, retain) NSMutableArray *words;
@property (nonatomic, retain) NSString *word;
@property (nonatomic, assign) int minLetters;
@property (nonatomic, assign) int maxLetters;
@property (nonatomic, assign) int numLetters;
@property (nonatomic, assign) BOOL correctGuess;
@property (nonatomic, assign) BOOL evil;

- (id)init;
- (void)parseByLength;
- (void)resetWords:(int)numLetters;
- (NSString *)guess:(NSString *) letter;
- (void)saveMinMaxLettersToDefaults;
- (NSString *)getTheWord;

- (NSString *)guess:(NSString *) letter withGuessed:(NSString *)guessed;

@end
