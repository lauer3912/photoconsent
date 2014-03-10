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

@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSData *signData;
@property (strong, nonatomic) NSString *dataTypeIdentifier;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) MFMessageComposeViewController *messageComposer;
@end




@implementation PMMessageActivity

- (id) init {
    
    
    if ((self = [super self])) {
        _messageComposer = [[MFMessageComposeViewController alloc] init];
        
    }
    return self;
   
}

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
   
    CFStringRef UTI = kUTTypeJPEG;
    _dataTypeIdentifier = (__bridge_transfer NSString *)(UTI);
    [activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        

        if (idx == 1) {
            _signData = (NSData*)obj;
            
            if ([MFMessageComposeViewController canSendAttachments]) {
                if ([MFMessageComposeViewController isSupportedAttachmentUTI:_dataTypeIdentifier]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        [_messageComposer addAttachmentData:_signData typeIdentifier:@"public.data" filename:@"Signature.jpeg"];
                    
                    });
                }
            
            }
            
        }
                if (idx == 4) {
             _imageData = (NSData*)obj;
            
            if ([MFMessageComposeViewController canSendAttachments]) {
                if ([MFMessageComposeViewController isSupportedAttachmentUTI:_dataTypeIdentifier]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        [_messageComposer addAttachmentData:_imageData typeIdentifier:@"public.data" filename:@"Image.jpeg"];
                        
                    });
                }
                        }
            
        }
        
  
        if (idx == 5) {
            _body = (NSString*)obj;
        }
        if (idx == 3) {
            
            
          //  CFStringRef UTI = kUTTypeJPEG;
          //  _dataTypeIdentifier = (__bridge_transfer NSString *)(UTI);
        }
        
    }];
    
}
- (UIViewController *)activityViewController {
    
    if ([MFMessageComposeViewController canSendText]) {
        
        _messageComposer.messageComposeDelegate = self;
        
        if ([MFMessageComposeViewController canSendSubject] )
            [_messageComposer setSubject:@"PhotoConsent"];
        
        [_messageComposer setBody:_body];
         return _messageComposer;
        
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
