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
#import "PMDisclaimerViewController.h"

@interface PMLoginActivity ()
<PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate>

    @property NSInteger imageCount;

    @property (strong, nonatomic)  PFLogInViewController *logInViewController;


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
    
    return resizeImage([UIImage imageNamed:@"234-cloud"], CGSizeMake(40.0, 21.25));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    
    _imageCount = 0;
    if ([activityItems[0] isKindOfClass:[NSNumber class]]) {
        
        _imageCount = [(NSNumber*)activityItems[0] integerValue];
        
        if (_imageCount > 0) {
            if ([_stopOfflineDelegate respondsToSelector:@selector(userDidLogout:)]) {
                [_stopOfflineDelegate userDidLogout:nil];
            }

        }
        
    }
    
}

- (UIViewController *)activityViewController {
    
    
    // Create the log in view controller
    _logInViewController = [[PMLoginViewController alloc] init];
    
    
    [_logInViewController setDelegate:self];
    
    // Create the sign up view controller
    PMSignUpViewController *signUpViewController = [[PMSignUpViewController alloc] init];
    
    [signUpViewController setDelegate:self];
    
    PFSignUpFields fields = (PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsAdditional | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton);
    
    
    
    [signUpViewController setFields:fields];;
    
    // Assign our sign up controller to be displayed from the login controller
    [_logInViewController setSignUpController:signUpViewController];
        
    return _logInViewController;
}

- (void)performActivity {
    
}

#pragma mark - PFLogInViewControllerDelegate methods

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
    
    if ([_refreshDelegate respondsToSelector:@selector(refreshAndCacheObjects)]) {
        [_refreshDelegate refreshAndCacheObjects];
    }

}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
       
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self activityDidFinish:YES];
}


#pragma mark - PFSignUpViewControllerDelegate methods

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:
   (NSDictionary *)info {
    
    if ([self infoComplete:info]) {
       
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *disclaimerAcknowledged = [defaults objectForKey:@"disclaimerAcknowledged"];
        // set acknowledged = YES if it is not already, otherwise leave alone
        if ([disclaimerAcknowledged boolValue] == YES) {
            return YES;
        } else {
            
            [self presentDisclaimerForAcceptanceWithSignupController:signUpController];
            return NO;
        }
        
        
    } else
        return NO;
    
   
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
       // Dismisses the PFSignUpViewController
     [self activityDidFinish:YES];
    
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
   //don't finish the activity her - let it return to the sign up form
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
    [self activityDidFinish:YES];
}

#pragma mark - Present disclaimer for acceptance
- (void)presentDisclaimerForAcceptanceWithSignupController:(PFSignUpViewController *)signUpController {
    
    //show disclaimer before sign up
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"];
    if ([vc isKindOfClass:[PMDisclaimerViewController class]]) {
        PMDisclaimerViewController *avc = (PMDisclaimerViewController*)vc;
       
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
        
        UIBarButtonItem *acceptBtn = [[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStyleBordered target:avc action:@selector(acceptDisclaimer:)];
        [avc.navigationItem setRightBarButtonItem:acceptBtn];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:avc action:@selector(cancel:)];
        
        [avc.navigationItem setLeftBarButtonItem:cancelBtn];
        
        [avc setModalPresentationStyle:UIModalPresentationFullScreen];
        [signUpController presentViewController:nc animated:YES completion:^{
            
        }];
        
    }
    
}

- (BOOL)infoComplete:(NSDictionary*)info {
    
    BOOL informationComplete = YES;
     
     // loop through all of the submitted data
     for (id key in info) {
         NSString *field = [info objectForKey:key];
         if (!field || field.length == 0) // check completion
             informationComplete = NO;
         break;
     }
    
     
     // Display an alert if a field wasn't completed
     if (!informationComplete) {
     
         [[[UIAlertView alloc] initWithTitle:@"Missing Information"
         message:@"Please enter all the information!"
         delegate:nil
         cancelButtonTitle:@"Ok"
         otherButtonTitles:nil] show];
     }
     return informationComplete;
         
}

@end