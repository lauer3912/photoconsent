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
#import "PMConsentDetailViewController.h"
#import "PMCompleteViewController.h"
#import "ConsentStore.h"
#import "Consent.h"


@interface PMCameraRollActivity ()
<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *referenceID;
@property (strong, nonatomic) UIImagePickerController *cameraController;

@end



@implementation PMCameraRollActivity


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
    
    return resizeImage([UIImage imageNamed:@"56-cloud"], CGSizeMake(40.0, 21.34));
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    if (isPaid()) {
         return YES;
    } else
        return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
   
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum] ) {
        
        
        _cameraController = [UIImagePickerController new];
        _cameraController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        _cameraController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        _cameraController.allowsEditing = YES;
        
        _cameraController.delegate = self;
        
        
        
        
    }
    
    //give the _sendercontroller a reference to the activity and the cameraController
    if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
        [(PMCloudContentsViewController*)_senderController setActivity:self];
        [(PMCloudContentsViewController*)_senderController setCameraController:_cameraController];
        
    }
    
}


- (UIViewController *)activityViewController {
   
    return _cameraController;
    
    
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
        
        
        if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
            //send image to the sendercontroller as it is the alertview delegate
            [(PMCloudContentsViewController*)_senderController setImage:_image];
        }
       
        
        
        //use a tag so we can identify the preview view controller if we return
        picker.topViewController.view.tag = 100;
        
        //add a reference ID
        UIAlertView *referenceID = [[UIAlertView alloc] initWithTitle:@"Reference Identifier" message:nil delegate:_alertViewDelegate cancelButtonTitle:@"Cancel" otherButtonTitles: @"Done",nil];
        [referenceID setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *textField = [referenceID textFieldAtIndex:0];
        [textField setTextColor:[UIColor blueColor]];
        [textField setPlaceholder:@"Add a photo identifier "];
        referenceID.tag = 2;
        [referenceID show];
        
    }
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
   [self activityDidFinish:YES]; 
}



@end
