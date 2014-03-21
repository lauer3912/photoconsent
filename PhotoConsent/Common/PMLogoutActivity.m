//
//  PMLogoutActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMLogoutActivity.h"
#import "PMFunctions.h"
#import <Parse/PFUser.h>


@interface PMLogoutActivity ()

@property (nonatomic, strong) NSArray* activityItems;
@end



@implementation PMLogoutActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"logoutActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Logout",@"Disconnect from Cloud");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"234-cloud"], CGSizeMake(40.0, 21.25));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    _activityItems = activityItems;
    
}
- (UIViewController *)activityViewController {
    
    return nil;
    
}

- (void)performActivity {
   
    [PFUser logOut];
    [self activityDidFinish:YES];
    if (![PFUser currentUser]) {
        if ([_delegate respondsToSelector:@selector(userDidLogout:)]) {
            [_delegate userDidLogout:self];
        }

    }
    
    
}


@end
