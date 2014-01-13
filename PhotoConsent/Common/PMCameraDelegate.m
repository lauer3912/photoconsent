//
//  PMCameraDelegate.m
//  Photoconsent
//
//  Created by Alex Rafferty on 19/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMCameraDelegate.h"
#import "PMCloudContentsViewController.h"
#import "AlbumContentsViewController.h"
#import "Consent.h"
#import "PMFunctions.h"


@interface PMCameraDelegate () <UIAlertViewDelegate>
{
    UIImagePickerController *cameraController;
}

@property (strong, nonatomic) id senderController;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *referenceID;
@end

@implementation PMCameraDelegate

- (void) startCamera:(id) sender {
    _senderController = sender; //keep reference

    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    // Delegate is self
    imagePicker.delegate = self;
    // Show image picker
    [(UIViewController*)sender presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    cameraController = picker;
    
    // Access the uncropped image from info dictionary
    _image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIAlertView *referenceID = [[UIAlertView alloc] initWithTitle:@"Reference Identifier" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Done",nil];
    referenceID.delegate = self;
    [referenceID setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [referenceID show];
    
   
}

#pragma mark - referenceID alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != -1) {
        _referenceID = [[alertView textFieldAtIndex:0] text];
       
    } else _referenceID = @"Not Assigned";
    
      
    // Dismiss picker, resize image and start the consent process
    [cameraController dismissViewControllerAnimated:YES completion:^{
        
        if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
            
            
            
            
            cloudPhoto(_image, _referenceID, dispatch_get_main_queue(), ^(id userPhoto) {
                
                PMCloudContentsViewController *cloudController = (PMCloudContentsViewController*)_senderController;
                
                [cloudController performSegueWithIdentifier:@"goToConsentScreens" sender:userPhoto];
                
            });
            
            
        } else if ([_senderController isKindOfClass:[AlbumContentsViewController class]]) {
            
            AlbumContentsViewController *albumController = (AlbumContentsViewController*)_senderController;
            
            //store a smaller version of the image for verification
            NSData *imageData = UIImageJPEGRepresentation(resizeImage(_image, CGSizeMake(640.0, 960.0)), 1.0f);

            
            Consent *userPhoto = [[Consent alloc] initWithReference:_referenceID imageFile:imageData];
            [albumController performSegueWithIdentifier:@"goToConsentScreens" sender:(Consent*)userPhoto];
        }
        
    }];
    
}


@end
