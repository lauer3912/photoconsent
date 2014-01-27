//
//  PMMessageActivity.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 25/01/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMMessageActivity.h"
#import "PMFunctions.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface PMMessageActivity () <MFMessageComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray* activityItems;
@property (strong, nonatomic) NSURL* assetURL;

@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *dataTypeIdentifier;
@property (strong, nonatomic) NSString *body;

@end


@implementation PMMessageActivity

+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"messageActivityType";
}

- (NSString *)activityTitle {
    
    return @"Message";
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"glyphicons_129_message_new"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    //6 activity items get passed in, namely: consent (Consent class), signature data, subject, dataTypeIdentifier, image data, and text (for body)
    _activityItems = activityItems;
    [activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx == 4) {
             _imageData = (NSData*)obj;
        }
  
        if (idx == 5) {
            _body = (NSString*)obj;
        }
        if (idx == 3) {
            _dataTypeIdentifier = (NSString*)obj;
        }
        
    }];
    
}
- (UIViewController *)activityViewController {
    
    if ([MFMessageComposeViewController canSendText]) {
       
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        messageComposer.messageComposeDelegate = self;
        [messageComposer setBody:_body];
        if ([MFMessageComposeViewController canSendSubject] )
            [messageComposer setSubject:@"PhotoConsent"];
        
        [messageComposer setBody:_body];
        return messageComposer;
        
        /* - adding image attachment is not working jan 27,2014
        BOOL didAddAttachment = NO;
        if ([MFMessageComposeViewController canSendAttachments]) {
            if ([MFMessageComposeViewController isSupportedAttachmentUTI:_dataTypeIdentifier]) {
                
                didAddAttachment = [messageComposer addAttachmentData:_imageData typeIdentifier:_dataTypeIdentifier filename:@"photoconsent.jpeg"];
                
            }
            if (didAddAttachment) {
                
                NSLog(@"Attachments %@", messageComposer.attachments );
                return messageComposer;
            }
            else
                return nil;
        } else
            return nil;
    
       */
    } else
        return nil;
}

- (void)performActivity {
    
    
}


#pragma mark -
#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message compose result = %@", @"Cancelled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Message compose result = %@", @"Sent");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message compose result = %@", @"Failed");
            break;
            
        default:
            break;
    }
   [self activityDidFinish:YES];
    
}

@end
