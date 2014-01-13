//
//  PMAppDelegate.m
//  Photoconsent
//
//  Created by Edward Wallitt on 24/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMAppDelegate.h"


@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup parse API
    [Parse setApplicationId:@"jCHTBRY8FeomshRh8Wl92MAJaBvwEqB3eFoEXvrj"
                  clientKey:@"Tx62CaFBE2yPpmKKo8KqylOBnxhfVrSTrjO7O44f"];
    
    [self setStandardUserDefaults];
      
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
    
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserDefaults.plist"];
    //if the UserDefaults.plist file is not found create it
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString* formatString =  [NSDateFormatter dateFormatFromTemplate:@"EdMMMhh:mma" options:0 locale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:formatString];
    NSNumber *noValue = [NSNumber numberWithBool:NO];
    NSString *error;
   
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                               [NSArray arrayWithObjects:@"Password not registered", @"User name not registered",noValue, [dateFormatter stringFromDate:[NSDate distantFuture]] ,[dateFormatter stringFromDate:[NSDate distantFuture]], nil]
                                   forKeys:[NSArray arrayWithObjects: @"cloudPassword", @"cloudUsername", @"disclaimerAcknowledged",@"disclaimerAcknowledgedDate", @"lastAppSession",nil]];
    
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
    [userDefaultsClear removeObjectForKey:@"cloudPassword"];
    [userDefaultsClear removeObjectForKey:@"cloudUsername"];
    [userDefaultsClear removeObjectForKey:@"disclaimerAcknowledged"]; //BOOL
    [userDefaultsClear removeObjectForKey:@"disclaimerAcknowledgedDate"];
    [userDefaultsClear removeObjectForKey:@"lastAppSession"];
    
    [NSUserDefaults resetStandardUserDefaults];
    
}


#pragma mark - Disclaimer alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != -1) {
        
        
    }
        
}

@end
