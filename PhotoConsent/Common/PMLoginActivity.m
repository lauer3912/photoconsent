//
//  PMLoginActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMLoginActivity.h"
#import "PMFunctions.h"
#import "PMLoginViewController.h"
#import "PMSignUpViewController.h"
#import <Parse/Parse.h>


@interface PMLoginActivity ()
<PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate>
@property (nonatomic, strong) NSArray* activityItems;
@end



@implementation PMLoginActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"loginActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Login",@"Login or Sign up");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"234-cloud"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    _activityItems = activityItems;
    
}
- (UIViewController *)activityViewController {
    
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[PMLoginViewController alloc] init];

     
    [logInViewController setDelegate:self];
    
    // Create the sign up view controller
    PFSignUpViewController *signUpViewController = [[PMSignUpViewController alloc] init];

    [signUpViewController setDelegate:self];
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    return logInViewController;
}

- (void)performActivity {
    
}

#pragma mark - PFLogInViewControllerDelegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self activityDidFinish:YES];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self activityDidFinish:YES];
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    } 
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
       // Dismisses the PFSignUpViewController
    //show disclaimer again even though already acknowledged on first app use
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"];
    
    [avc setModalPresentationStyle:UIModalPresentationFullScreen];
    [signUpController presentViewController:avc animated:YES completion:^{
        
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self activityDidFinish:YES];
        });
        
        
    }];
    
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
    [self activityDidFinish:YES];
}



@end
