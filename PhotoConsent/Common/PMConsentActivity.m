//
//  PMConsentActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 31/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMConsentActivity.h"
#import "PMFunctions.h"
#import "PMConsentViewController.h"
#import "Consent.h"
#import <Parse/Parse.h>


@interface PMConsentActivity () 
@property (nonatomic, strong) id selectedObject;
@end


@implementation PMConsentActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    
    return @"consentActivityType";
}

- (NSString *)activityTitle {
    
    return  NSLocalizedString(@"Consent", @"Consent details");
}

- (UIImage *)activityImage {
    
    return [UIImage imageNamed:@"consent-tabicon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    __block BOOL canPerform = NO;
    [activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PFObject class]] || [obj isKindOfClass:[Consent class]]) {
            canPerform = YES;
            *stop = YES;
        }
    }];
    
    return canPerform;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    [activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PFObject class]] || [obj isKindOfClass:[Consent class]]) {
            _selectedObject = obj;
        }
    }];
    
}
- (UIViewController *)activityViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"consentNavController"];
    
    UIViewController *avc = nvc.viewControllers[0];
    if ([avc isKindOfClass:[PMConsentViewController class]]) {
        [(PMConsentViewController*)avc setActivityConsent:self];
        [(PMConsentViewController*)avc setM_selectedPhoto:_selectedObject];
        
    }
    
    return nvc;
}

- (void)performActivity {
     
}



@end
