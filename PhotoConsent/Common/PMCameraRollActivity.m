//
//  PMCameraRollActivity.m
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMCameraRollActivity.h"
#import "PMFunctions.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PMCloudContentsViewController.h"


@interface PMCameraRollActivity ()
<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray* activityItems;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *referenceID;

@end



@implementation PMCameraRollActivity


- (id) initWithSenderController:(UIViewController*)controller {
    
    if (self = [super init]) {
        _senderController = controller;
    }
    
    return self;
}



+ (UIActivityCategory)activityCategory {
    
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    
    return @"cameraRollActivityType";
}

- (NSString *)activityTitle {
    
    return NSLocalizedString(@"Camera Roll to Cloud",@"Camera Roll");
}

- (UIImage *)activityImage {
    
    return resizeImage([UIImage imageNamed:@"56-cloud"], CGSizeMake(40.0, 40.0));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    _activityItems = activityItems;
    
}
- (UIViewController *)activityViewController {
    UIImagePickerController *mediaUI;
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum] ) {
        
        mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = YES;
        
        mediaUI.delegate = self;
    }
    
    return mediaUI;
    
    
}

- (void)performActivity {
    
    
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            _image = editedImage;
        } else {
            _image = originalImage;
        }
        UIAlertView *referenceID = [[UIAlertView alloc] initWithTitle:@"Reference Identifier" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Done",nil];
        referenceID.delegate = self;
        [referenceID setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [referenceID show];
    }
    
    
    [self activityDidFinish:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
   [self activityDidFinish:YES]; 
}

#pragma mark - referenceID alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != -1) {
        _referenceID = [[alertView textFieldAtIndex:0] text];
        
        cloudPhoto(_image, _referenceID, dispatch_get_main_queue(), ^(id userPhoto) {
            
            PMCloudContentsViewController *cloudController = (PMCloudContentsViewController*)_senderController;
            
            [cloudController performSegueWithIdentifier:@"goToConsentScreens" sender:userPhoto];
            
        });
        
    } else {
        _referenceID = nil;
        
        
    }
    
    
    
    
    
}


@end
