//
//  PMDisclaimerActivity.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 26/01/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMDisclaimerActivity.h"
#import "PMFunctions.h"
#import "PMDisclaimerViewController.h"

@implementation PMDisclaimerActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"disclaimerActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Disclaimer", @"Disclaimer notice");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"glyphicons_259_log_file"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    
    
}
- (UIViewController *)activityViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"];
    
    [(PMDisclaimerViewController*)avc setActivity:self]; //need a reference to the activity so we can finish it
    
    return avc;
}

- (void)performActivity {
    
    
    
}





@end
