//
//  PMFeedbackActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 30/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMFeedbackActivity.h"
#import "PMFunctions.h"
#import "UIColor+More.h"


@interface PMFeedbackActivity () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MFMailComposeViewController *mailComposer;

@end


@implementation PMFeedbackActivity


- (id) initWithSenderController:(UIViewController*)controller shareActivityType:(PMFeedbackActivityShareType)shareActivityType;{
    
    if (self = [super init]) {
        _senderController = controller;
        _shareActivityType = shareActivityType;
        _mailComposer = [[MFMailComposeViewController alloc] init];
    }
    
    return self;
}



+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    
    return @"CustomMailActivityType";
}

- (NSString *)activityTitle {
    
    if (_shareActivityType == shareActivityTypeFeedback) {
        return @"Feedback";
    } else
        return @"Share";

        
    
}

- (UIImage *)activityImage {
    
    if (_shareActivityType == shareActivityTypeFeedback) {
        return resizeImage([UIImage imageNamed:@"feedback"], CGSizeMake(40.0, 27.5));
    } else
        return resizeImage([UIImage imageNamed:@"18-envelope"], CGSizeMake(40.0, 27.5));
    
    
    
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
   
       return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    
    _mailComposer.mailComposeDelegate = self;
    [_mailComposer.navigationBar setTintColor:[UIColor turquoise]];
    if (_shareActivityType == shareActivityTypeFeedback) {
        [_mailComposer setSubject:@"PhotoConsent"];
        [_mailComposer setToRecipients:@[@"feedback@photoconsent.com"]];
        [_mailComposer setMessageBody:@"Please enter your comments here" isHTML:NO];
    } else if (_shareActivityType == shareActivityTypeWithImages) {
                [_mailComposer setSubject:@"Image from PhotoConsent"];
                [_mailComposer setMessageBody:activityItems[3] isHTML:NO];
                NSData *signatureData = activityItems[1];
                NSData *imageData = activityItems[2];
                [_mailComposer addAttachmentData:signatureData mimeType:@"image/jpeg" fileName:@"consent_image.jpg"];
                [_mailComposer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"medical_image.jpg"];
          } else if (_shareActivityType == shareActivityTypePromote) {
                    [_mailComposer setSubject:@"Image from PhotoConsent"];
                    [_mailComposer setMessageBody:activityItems[0] isHTML:NO];
                
                }
    
}
- (UIViewController *)activityViewController {
       return nil;
}

- (void)performActivity {
    
    [[(UIViewController*)_senderController presentedViewController]  presentViewController:_mailComposer animated:YES completion:^{
      
   }];;
    
}


#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self activityDidFinish:YES];
        
}

@end
