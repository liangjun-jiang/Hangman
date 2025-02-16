//
//  RootViewController.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "RootViewController.h"
#import "InAppRageIAPHelper.h"
#import "Reachability.h"

@implementation RootViewController
@synthesize hud = _hud;

#pragma mark -
#pragma mark View lifecycle
-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.title = @"Remove Ads";
}

- (void)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - misc

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.hud = nil;
    
}

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.tableView.hidden = FALSE;    
    
    [self.tableView reloadData];
    
}

- (void)timeout:(id)arg {
    
    _hud.labelText = @"Timeout!";
    _hud.detailsLabelText = @"Please try again later.";
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

- (void)updateInterfaceWithReachability: (Reachability*) curReach {
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {

    self.tableView.hidden = TRUE;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];    
    if (netStatus == NotReachable) {        
        NSLog(@"No internet connection!");        
    } else {        
        if ([InAppRageIAPHelper sharedHelper].products == nil) {
            
            [[InAppRageIAPHelper sharedHelper] requestProducts];
            self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            _hud.labelText = @"Loading comics...";
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
            
        }        
    }

    [super viewWillAppear:animated];
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[InAppRageIAPHelper sharedHelper].products count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
	// Configure the cell.
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:indexPath.row];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];

    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = formattedString;

    if ([[InAppRageIAPHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {        
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;     
    }

    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (IBAction)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;    
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[InAppRageIAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"Buying ...";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
    
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];    
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    [self.tableView reloadData];    
    
}

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                         message:transaction.error.localizedDescription 
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.hud = nil;
}

//- (void)dealloc {
//    [_hud release];
//    _hud = nil;
//    [super dealloc];
//}


@end

