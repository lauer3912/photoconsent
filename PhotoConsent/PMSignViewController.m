//
//  PMSignViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMSignViewController.h"
#import "PMTouchTrackerView.h"
#include <QuartzCore/QuartzCore.h>
#import "PMCompleteViewController.h"
#import "Consent.h"


@interface PMSignViewController ()

@property (strong, nonatomic) IBOutlet PMTouchTrackerView *signatureView;
- (IBAction)clearSignature:(id)sender;

@end

@implementation PMSignViewController

- (void)loadView
{
    [super loadView];
}

- (IBAction)clearSignature:(id)sender
{
    [_signatureView clear];
}

- (IBAction)pressedCompleteConsent:(id)sender {
    // transform the uiview into an image
    UIGraphicsBeginImageContext(self.signatureView.bounds.size);
    [_signatureView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *signature = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // convert the image, save it to the parse object
    NSData *imageData = UIImageJPEGRepresentation(signature, 1.0f);
    
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
        [_userPhoto setValue:imageFile forKey:@"consentSignature"];
    } else if ([_userPhoto isKindOfClass:[Consent class]])
        [_userPhoto setValue:imageData forKey:@"consentSignature"];
    
    
    // transition to the final screen
    [self performSegueWithIdentifier:@"goToConfirmationScreen" sender:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToConfirmationScreen"]) {
        PMCompleteViewController *controller = segue.destinationViewController;
        controller.userPhoto = _userPhoto;
    }
}

#pragma - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self clearSignature:self];
}

@end
