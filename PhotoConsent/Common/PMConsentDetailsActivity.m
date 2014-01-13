//
//  PMConsentDetailsActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMConsentDetailsActivity.h"
#import "PMFunctions.h"
#import "PMReferenceViewController.h"

@interface PMConsentDetailsActivity ()

@property (nonatomic, strong) NSArray* activityItems;

@end



@implementation PMConsentDetailsActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"consentDetailsActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Consent Details", @"Consent Details");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"settings-tabicon"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    _activityItems = activityItems;
    
}
- (UIViewController *)activityViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
     
    UINavigationController* navController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"referenceTableViewController"];
    PMReferenceViewController* referenceController = navController.viewControllers[0];
    
    [referenceController setActivity:self]; //need a reference to the activity so we can finish it
    
    return navController;
}

- (void)performActivity {
    
    
    
}



@end
