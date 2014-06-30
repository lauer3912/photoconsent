//
//  PMAppDelegate.m
//  Photoconsent
//
//  Created by Edward Wallitt on 24/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMAppDelegate.h"
#import "PMTextConstants.h"
#import "Reachability.h"
#import "VerifyStoreReceipt.h"

@implementation PMAppDelegate

static  NSDateFormatter *dateFormatter;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup parse API
    [Parse setApplicationId:@"jCHTBRY8FeomshRh8Wl92MAJaBvwEqB3eFoEXvrj"
                  clientKey:@"Tx62CaFBE2yPpmKKo8KqylOBnxhfVrSTrjO7O44f"];
    
    [self setStandardUserDefaults];
  
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    //In-App Purchase transaction queue observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    //if the isPaid value has been set = 3 by the receipt verification then the receipt verification failed and we should request a new receipt from the app-store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isPaid = [defaults valueForKey:@"Paid"];
    if (isPaid.intValue == 3) {
        //wait a few seconds to give the reachability monitor a chance to set networkStatusu
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestReceipt];
        });
    }
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark User Defaults

- (void)setStandardUserDefaults
{
    
    formatter();
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserDefaults.plist"];
    //if the UserDefaults.plist file is not found create it
    NSNumber *noValue = [NSNumber numberWithBool:NO];
    NSString *error;
   
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                               [NSArray arrayWithObjects:noValue,noValue,[dateFormatter stringFromDate:[NSDate distantFuture]], nil]
                                   forKeys:[NSArray arrayWithObjects:@"Paid",@"disclaimerAcknowledged",@"disclaimerAcknowledgedDate",nil]];
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        
    }
    else {
        
        
    }
    
    
    //load and register the registered defaults
    NSDictionary *userDefaultsValuesDict;
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:plistPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
    
    
}

- (void) clearUserDefaults {
    
    NSUserDefaults* userDefaultsClear = [NSUserDefaults standardUserDefaults];
    [userDefaultsClear removeObjectForKey:@"Paid"];
    [userDefaultsClear removeObjectForKey:@"disclaimerAcknowledged"]; //BOOL
    [userDefaultsClear removeObjectForKey:@"disclaimerAcknowledgedDate"];
    
    [NSUserDefaults resetStandardUserDefaults];
    
}


#pragma mark - Disclaimer alertview delegate not used

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != -1) {
        
        
    }
        
}


#pragma mark -
#pragma mark - In-App Purchase SKPaymentTransactionObserver protocol methods
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                
                [self saveTransactionToDefaults:transaction];
                [self showConfirmation:@"Thank you for your purchase"];
                [self sendNotificationToObservers];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                
                [self saveTransactionToDefaults:transaction];
                [self showConfirmation:@"Your purchase has been restored"];
                [self sendNotificationToObservers];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                
                [queue finishTransaction:transaction];
                break;
            
            default:
                break;
        }
        
    }
    
}

- (void) showConfirmation:(NSString*)message {
    UIAlertView *purchased = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [purchased show];
    
}


- (void) saveTransactionToDefaults:(SKPaymentTransaction*) transaction {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@1 forKey:@"Paid"];
    
    
}


#pragma mark - Notification to transaction observers
- (void) sendNotificationToObservers {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"AppStorePurchaseNotification" object:nil];
    });
    
}


#pragma mark -
#pragma mark - Date format function
void formatter()  {
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSLocale *ukLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        [dateFormatter setLocale:ukLocale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
}

#pragma mark - Reachability

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser]) {
            // executed hostReach reachable block
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
    };
    
    [hostReach startNotifier];
}

#pragma mark - Refesh receipt request
- (void)requestReceipt {
    if ([self isParseReachable]) {
        
        //our monthly user has no receipt - send ReceiptRefreshRequest
        SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
        request.delegate = self;
        [request start];

        
        
    } else {
        
        //no connection - set Paid = NO and ask user to try again  later
        //set Paid = NO
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@0 forKey:@"Paid"];

        
    }
    
}


#pragma mark -
#pragma mark - SKRequestDelegate Methods

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
   
    //set Paid = NO
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@0 forKey:@"Paid"];
    
    
}

- (void)requestDidFinish:(SKRequest *)request {
    
    /*
     we only asked for this receipt to be refreshed because we could not verify the receipt. Seems we now have a receipt so try again to set the Paid status
     */
    
    localReceiptSubscriptionIsCancelled();
        
}


@end
