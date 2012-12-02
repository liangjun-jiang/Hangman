//
//  WordLookupViewController.m
//  Hangman
//
//  Created by LIANGJUN JIANG on 10/6/12.
//
//

#import "WordLookupViewController.h"

#define DICTONARY_URL @"http://www.bing.com/Dictionary/search?q="
#define HANGMAN_INSTRUCTION @"http://www.theproblemsite.com/games/hangmanvariation.asp"

@interface WordLookupViewController ()<UIWebViewDelegate>

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* activityIndicator;

//@property (nonatomic,retain) IBOutlet UINavigationBar* navBar;
@property (nonatomic,retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *urlStr;


@end

@implementation WordLookupViewController
//@synthesize navBar = _navBar;
@synthesize webView = _webView;
@synthesize word = _word;
//@synthesize delegate = _delegate;
@synthesize activityIndicator = _activityIndicator;


//- (IBAction)done:(id)sender {
//    
//    [self.delegate wordLookupViewControllerDidFinish:self];
//    
//}

- (void)onDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id) initWithWord:(NSString *)mWord {
    
    self = [super initWithNibName:@"WordLookupViewController"  bundle:nil];
    if (self){
        self.word = mWord;
    }
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    CGSize size = CGSizeMake(320.0,460.0);
//    self.contentSizeForViewInPopover = size;
    
    self.activityIndicator.hidden = YES;
    self.title = self.word;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneItem;
//    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"blackboard"]];
    // Do any additional setup after loading the view from its nib.
    NSURL *url;
    if (self.word) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DICTONARY_URL,self.word]];
    } else {
        url = [NSURL URLWithString:HANGMAN_INSTRUCTION];
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.webView = nil;
    self.word = nil;
    self.activityIndicator = nil;
}



@end
