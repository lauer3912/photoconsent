//
//  PMAccountActivity.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 26/01/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMAccountActivity.h"
#import "PMFunctions.h"
#import "PMAccountViewController.h"


@implementation PMAccountActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"accountActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Account", @"Account details");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"glyphicons_003_user"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    
    
}
- (UIViewController *)activityViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
    
    [(PMAccountViewController*)avc setActivity:self]; //need a reference to the activity so we can finish it
    
    return avc;
}

- (void)performActivity {
    
    
    
}




@end
