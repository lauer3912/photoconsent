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


@interface PMConsentActivity () 
@property (nonatomic, strong) NSArray* activityItems;
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
    
    return resizeImage([UIImage imageNamed:@"consent-tabicon"], CGSizeMake(40.0, 40.0));
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
    
    _activityItems = activityItems;
    
}
- (UIViewController *)activityViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    __block UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"consentViewController"];
    if ([avc isKindOfClass:[PMConsentViewController class]]) {
        [(PMConsentViewController*)avc setActivityConsent:self];
        [_activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[PFObject class]] || [obj isKindOfClass:[Consent class]]) {
              [(PMConsentViewController*)avc setM_selectedPhoto:obj];
            }
        }];
    }
    return avc;
}

- (void)performActivity {
     
}


@end
