//
//  PMWorkOfflineActivity.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 12/03/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMWorkOfflineActivity.h"
#import "PMFunctions.h"
#import <Parse/PFUser.h>
#import "ConsentStore.h"
#import "PMCloudContentsViewController.h"



@interface PMWorkOfflineActivity ()
 @property NSInteger imageCount;
 @property (strong, nonatomic) NSString *activityName;

@end


@implementation PMWorkOfflineActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"workOfflineActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(_activityName,@"Work offline");
}

- (UIImage *)activityImage {
    
    return [UIImage imageNamed:@"offline"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    _imageCount = 0; //initialise
    if ([activityItems[0] isKindOfClass:[NSNumber class]]) {
        
        _imageCount = [(NSNumber*)activityItems[0] integerValue];
    }
    
    if ([activityItems[1] isKindOfClass:[NSString class]]) {
        
        _activityName = (NSString*)activityItems[1];
    }
    
    return YES;

}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    
    
}
- (UIViewController *)activityViewController {
    
    return nil;
    
}

- (void)performActivity {
    
    
    [self activityDidFinish:YES];
    //check user is logged out
    if (![PFUser currentUser]) {
        //toggle between start/stop offline with same activity depending on imagecount
        if (_imageCount == 0) {
            //Start
            if ([_offlineDelegate respondsToSelector:@selector(loadAndCacheDeviceImages:)]) {
                [_offlineDelegate loadAndCacheDeviceImages:self];
            }
        } else if ([_offlineDelegate respondsToSelector:@selector(userDidLogout:)]) {
            [_offlineDelegate userDidLogout:nil];
        }
       
        
    }
    
}


@end
