//
//  PMCameraDelegate.m
//  Photoconsent
//
//  Created by Alex Rafferty on 19/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMCameraDelegate.h"
#import "PMCloudContentsViewController.h"
#import "Consent.h"
#import "PMFunctions.h"
#import "PMConsentDetailViewController.h"

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
    [referenceID setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [referenceID show];
    
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
     [picker dismissViewControllerAnimated:YES completion:^{
    
     }];
}

#pragma mark - referenceID alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        _referenceID = [[alertView textFieldAtIndex:0] text];
        // Dismiss picker, resize image and start the consent process
        
        PMCloudContentsViewController* svc = (PMCloudContentsViewController*)_senderController;
        
        svc.shouldDim = YES;

        
        [cameraController dismissViewControllerAnimated:YES completion:^{
            
            if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
                

                cloudPhoto(_image, _referenceID, dispatch_get_main_queue(), ^(id userPhoto) {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                    PMConsentDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"consentDetail"];
                    [vc setUserPhoto:userPhoto];
                    
                    
                    [[_senderController navigationController] pushViewController:vc animated:NO];
                });
                
                
            }
           
        }];
        
    
    } else {
        
        [cameraController dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }
    
      
    }


@end
