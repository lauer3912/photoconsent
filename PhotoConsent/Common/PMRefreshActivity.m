//
//  PMRefreshActivity.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 11/03/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMRefreshActivity.h"
#import "PMFunctions.h"
#import <Parse/PFUser.h>


@implementation PMRefreshActivity


+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {

    return @"refreshActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Refresh",@"Refresh Cloud");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"01-refresh"], CGSizeMake(30.0, 32.4));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    BOOL saving = _isSaving;
    
    return !saving;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    
}
- (UIViewController *)activityViewController {
    
    return nil;
    
}

- (void)performActivity {
    
    [self activityDidFinish:YES];
    
    if ([_refreshDelegate respondsToSelector:@selector(refreshAndCacheObjects)]) {
        [_refreshDelegate refreshAndCacheObjects];
    }
    
}


@end
