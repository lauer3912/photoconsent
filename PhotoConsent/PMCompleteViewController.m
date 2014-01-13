//
//  PMCompleteViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMCompleteViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "Consent.h"
#import "PMFunctions.h"
#import "ConsentStore.h"
#import "PMTextConstants.h"
#import "PMCloudContentsViewController.h"


@interface PMCompleteViewController ()

@end

@implementation PMCompleteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Complete consent

- (IBAction)completeAndUpload:(id)sender {
   
    
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        
        
        
        [_userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //add the new object/photo to the allImage array in the cloud Viewcontroller
                NSMutableArray *allimages = [(PMCloudContentsViewController*)self.navigationController.viewControllers[0] allImages];
                [allimages addObject:_userPhoto];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                //save the image also to the album
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    PFFile *theImage = [_userPhoto valueForKey:@"imageFile"];
                    UIImage *image = [UIImage imageWithData:[theImage getData]];;
                    //        UIImage *waterMarkedImg = [self generateWatermarkForImage:image];
                    [self saveImageToAlbum:image withConsent:nil];
                    
                });
            } else
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }];
       
        
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Consent *deviceConsent = (Consent*)_userPhoto;
            NSData *imageData = deviceConsent.imageFile;
            UIImage *image = [UIImage imageWithData:imageData];
            [self saveImageToAlbum:image withConsent:deviceConsent];
        });
        
    }
    
    
}
- (void) saveImageToAlbum:(UIImage*)image withConsent:(Consent*)deviceConsent;  {
    
    //save to PhotoConsent album
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    //use ALAssetLibrary category methods
   [lib saveImage:image toAlbum:@"PhotoConsent" withCompletionBlock:^(NSURL* albumAssetURL, NSError *error) {
       
       
        if (error!=nil) {
            NSString *errorMessage = @"Error saving to album\n";
            if ([error userInfo]) {
                errorMessage = [errorMessage stringByAppendingString:[[error userInfo] valueForKey:NSLocalizedDescriptionKey]];
            }
            
            UIAlertView *reportError = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [reportError show];
            
        } else {
            // NSAssert(albumAssetURL, @"nil value not allowed for assetURL");
            
            if (albumAssetURL) {
                if ([_userPhoto isKindOfClass:[PFObject class]]) {
                    [self createDeviceConsentFromPFObjectForAssetAtURL:albumAssetURL];
                   
                }
                else {
                    
                    [deviceConsent setAssetURL:albumAssetURL];
                    [deviceConsent setCreated:[NSDate date]];
                    [self saveDeviceConsent:deviceConsent];

                }
            }
        }
            
    }];
    
    
}

- (void) createDeviceConsentFromPFObjectForAssetAtURL:(NSURL*)newAssetURL {
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        PFFile *theImage = [_userPhoto valueForKey:@"imageFile"];
        NSString *reference = [_userPhoto valueForKey:@"referenceID"];
        NSString *patientName = [_userPhoto valueForKey:@"patientName"];
        NSString *patientEmail = [_userPhoto valueForKey:@"patientEmail"];
        
        NSNumber *assessment = [_userPhoto valueForKey:@"Assessment"];
        NSNumber *education = [_userPhoto valueForKey:@"Education"];
        NSNumber *publication = [_userPhoto valueForKey:@"Publication"];
        PFFile *signature = [_userPhoto valueForKey:@"consentSignature"];
    
        Consent *deviceConsent = [[Consent alloc] initWithReference:reference imageFile:[theImage getData]];
        
        deviceConsent.patientName = patientName;
        deviceConsent.patientEmail = patientEmail;
        deviceConsent.Assessment = assessment;
        deviceConsent.Education = education;
        deviceConsent.Publication = publication;
        deviceConsent.consentSignature = [signature getData];
        deviceConsent.assetURL = newAssetURL;
        deviceConsent.created = [NSDate date];
        [self saveDeviceConsent:deviceConsent];
        
       
    }
    
}

- (void)saveDeviceConsent:(Consent*)deviceConsent {
   //dispatch queue
    ConsentStore *store = [ConsentStore sharedDeviceConsents];
    [store addDeviceConsent:deviceConsent];
    [store saveChanges];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"consentCompleted"]) {
        NSLog(@"the upload should have been performed here");
    }
}

#pragma mark -
#pragma mark - Email patient consent

- (IBAction)emailPatientConsent:(UIButton *)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        
        // set the recipient as the patient
        NSArray *recipients = [[NSArray alloc] initWithObjects:[_userPhoto valueForKey:@"patientEmail"], nil];
        [composer setToRecipients:recipients];
        
        // set the subject
        [composer setSubject:@"Photoconsent Image and Consent"];
        
        // setup the content for the email
        NSMutableString *emailBody = [NSMutableString stringWithFormat:@"<p><strong>Consent details for medical image taken by your healthcare professional using PhotoConsent</strong></p>"];
        
        // add basic patient details
        NSString *patientName = [NSString stringWithFormat:@"<p><strong>Patient Name</strong>: %@</p>", [_userPhoto valueForKey:@"patientName"]];
        NSString *patientEmail = [NSString stringWithFormat:@"<p><strong>Patient Email</strong>: %@ <p>", [_userPhoto valueForKey:@"patientEmail"]];
        [emailBody appendString:patientName];
        [emailBody appendString:patientEmail];
        
        // create the content of the consent
        BOOL isAssessment = [[_userPhoto valueForKey:@"Assessment"] boolValue];
        BOOL isEducation = [[_userPhoto valueForKey:@"Education"] boolValue];
        BOOL isPublication = [[_userPhoto valueForKey:@"Publication"] boolValue];
        
        if (isAssessment) {
            NSString *assessment = [NSString stringWithFormat:@"<p>%@<p>", kPMTextConstants_Assessment];
            [emailBody appendString:assessment];
        }
        if (isEducation) {
            NSString *education = [NSString stringWithFormat:@"<p>%@</p>", kPMTextConstants_Education];
            [emailBody appendString:education];
        }
        if (isPublication) {
            NSString *publication = [NSString stringWithFormat:@"<p>%@</p>", kPMTextConstants_Publication];
            [emailBody appendString:publication];
        }
        
        // set the message body
        [composer setMessageBody:emailBody isHTML:YES];
        
        NSData *signatureData, *imageData;
        if ([_userPhoto isKindOfClass:[PFObject class]]) {
            // add the signature
            PFFile *signImage = [_userPhoto valueForKey:@"consentSignature"];
            signatureData = [signImage getData];
            // add the image
            PFFile *theImage = [_userPhoto valueForKey:@"imageFile"];
            imageData = [theImage getData];
        } else {
            Consent *deviceConsent = (Consent*)_userPhoto;
            signatureData = deviceConsent.consentSignature;
            imageData = deviceConsent.imageFile;
        }
        [composer addAttachmentData:signatureData mimeType:@"image/jpeg" fileName:@"consent_image.jpg"];
        [composer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"medical_image.jpg"];
        
        [self presentViewController:composer animated:YES completion:nil];
    } else {
        UIAlertView *noMailAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry. This device cannot send mail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noMailAlert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - watermark attempts that don't work, at least with icon-small.png
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    
    return [UIImage imageWithCGImage:masked];
    
}

-(UIImage *) generateWatermarkForImage:(UIImage *) mainImg{
    UIImage *backgroundImage = mainImg;
    UIImage *watermarkImage = [UIImage imageNamed:@"icon-Small.png"];
    
    
    //Now re-drawing your  Image using drawInRect method
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    // set watermark position/frame a s(xposition,yposition,width,height)
    [watermarkImage drawInRect:CGRectMake(backgroundImage.size.width - watermarkImage.size.width, backgroundImage.size.height - watermarkImage.size.height, watermarkImage.size.width, watermarkImage.size.height)];
    
    // now merging two images into one
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


@end
