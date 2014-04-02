//
//  PMUpgradeViewController.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 17/03/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMUpgradeViewController.h"
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"
#import "PMFunctions.h"
#import "UIColor+More.h"

@interface PMUpgradeViewController ()
<SKProductsRequestDelegate,MBProgressHUDDelegate>

@property (nonatomic, strong) NSArray *products;
@property (weak, nonatomic) IBOutlet UILabel  *productName;
@property (weak, nonatomic) IBOutlet UILabel  *productDesc;
@property (weak, nonatomic) IBOutlet UILabel  *productPrice;
@property (weak, nonatomic) IBOutlet UIButton  *upgradeButton;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

NSString *const kPMUpgradeButtonTitleUpgrade = @"Upgrade now";
NSString *const kPMUpgradeButtonTitleRestore = @"Restore purchase";

@implementation PMUpgradeViewController

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
    
    [self setUpgradeButtonState];
    // register for NSNotification on subscription purchase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModalForm:) name:@"AppStorePurchaseNotification" object:nil];

}

- (void) setUpgradeButtonState{
    [self.view setBackgroundColor:[UIColor turquoise]];
    if (isPaid()) {
        [_upgradeButton setBackgroundColor:[UIColor darkGrayColor]];
        [_upgradeButton setTitleColor:[UIColor brightOrange] forState:UIControlStateNormal];
        [_upgradeButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
        [_upgradeButton setTitle:kPMUpgradeButtonTitleRestore forState:UIControlStateNormal];
    } else {
        [_upgradeButton setBackgroundColor:[UIColor brightOrange]];
        [_upgradeButton setTitleColor:[UIColor turquoise] forState:UIControlStateNormal];
        [_upgradeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_upgradeButton setTitle:kPMUpgradeButtonTitleUpgrade forState:UIControlStateNormal];
        
    }
        
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self getInAppProducts];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



/* In-App purchase
 *
 * The In-App Purchase workflow is as follows:
 *  1. Ask the App Store to return an array of valid product identifiers
 *  2. use the product identifers to create a products request
 *  3. the App Store sends a response to the request's delegate .i.e. an array of valid products previously set up in the App Store
 *  4. when the user selects the product the App Store effectively takes over the transaction
 */

#pragma mark -
#pragma mark - In-App Purchase

-(void)getInAppProducts {
    
    
    NSArray *productIdentifiers = @[@"PhotoConsent14"];
    [self validateProductIdentifiers:productIdentifiers];
    
}



// Custom method
- (void) validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
    
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (!_products)
        _products = [NSArray arrayWithArray:response.products];
    else
      _products = response.products;
    
    [self updateLabels];
    
    for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers) {
        // Handle any invalid product identifiers.
        NSLog(@"Invalid product id: %@" , invalidProductIdentifier);
    }
    
}

- (void)updateLabels {
    
    SKProduct *product = [_products objectAtIndex:0];
   
    [_productName setAttributedText:[self attributedStringForText:product.localizedTitle]];
    [_productDesc setText:product.localizedDescription];
    [_productPrice setText:[self formatPriceForProduct:product]];
    
}

- (NSString*) formatPriceForProduct:(SKProduct*)product {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return [numberFormatter stringFromNumber:product.price];
    
    
}

#pragma mark -
#pragma mark - Set up and Show HUD progress
- (void) showHUD {
    
    if (!_HUD) {
        _HUD =  [[MBProgressHUD alloc] initWithView:self.view];
    }
    [_HUD setAnimationType:MBProgressHUDAnimationFade];
    [_HUD setBackgroundColor:[UIColor clearColor]];
    [_HUD setOpacity:0.5];
    [self.view addSubview:_HUD];
    [_HUD show:YES];
    [_HUD hide:YES afterDelay:1.25];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_HUD removeFromSuperview];
        _HUD = nil;
    });
}


- (IBAction)didPressUpgradeButton:(id)sender {
    
    /*
     * identify the selected App Store product and create an SKMutablePayment to add to the SKPaymentQueue.
     * The SKPaymentQueue manages the transaction and send call back result to its delegate which
     * is located in the Application Delegate in order to catch all transactions, including any
     * that may have been suspended
     *
     * When notified of a successful transaction the final step (after making available the purchased content) is to call the transaction finish method.
     *
     */
    
    if ([[(UIButton*)sender currentTitle] isEqualToString:kPMUpgradeButtonTitleUpgrade]) {
        
        SKProduct *product = [_products objectAtIndex:0];
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = 1;
        
        
        NSString *userName = @"NewSubscription" ;
        [payment setApplicationUsername:userName];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self showHUD];
    } else {
        
        //restore here
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        [self showHUD];

    }

}

#pragma mark - AtrributedString method
-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkGrayColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:19.0], NSTextEffectAttributeName:NSTextEffectLetterpressStyle} range:range];
    
    return attrMutableString;
}


- (IBAction)dismissModalForm:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AppStorePurchaseNotification" object:nil];
        
    }];
}


@end
