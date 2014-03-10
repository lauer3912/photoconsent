//
//  PMFeedbackActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 30/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMFeedbackActivity.h"
#import "PMFunctions.h"

@interface PMFeedbackActivity () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray* activityItems;
@end


@implementation PMFeedbackActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    
    return @"feedbackActivityType";
}

- (NSString *)activityTitle {
    
    return @"Feedback";
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"18-envelope"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    _activityItems = activityItems;
    
}
- (UIViewController *)activityViewController {
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"PhotoConsent"];
    [mailComposer setToRecipients:@[@"feedback@photoconsent.com"]];
    [mailComposer setMessageBody:@"Please enter your comments here" isHTML:NO];
    return mailComposer;
}

- (void)performActivity {
 
   
    
}


#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self activityDidFinish:YES];
        
}

@end
