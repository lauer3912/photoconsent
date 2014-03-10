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
#import  <Parse/Parse.h>
#import  "AlbumContentsViewController.h"



@interface PMCompleteViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel* label1;
@property (weak, nonatomic) IBOutlet UILabel* label2;
@property (weak, nonatomic) IBOutlet UILabel* label3;
@property (weak, nonatomic) IBOutlet UIButton* emailBtn;
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
    NSData* data;
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        PFFile *imagefile = [_userPhoto valueForKey:@"imageFile"];
        //the image data should be cached within userPhoto but check. If it's not skip and leave it to the asynchronous save processes
        if (imagefile.isDataAvailable) {
            
            data = [imagefile getData];
            _imageView.image = [UIImage imageWithData:data];
        }
    } else {
        data = [_userPhoto valueForKey:@"imageFile"];
        _imageView.image = [UIImage imageWithData:data];
        
    }
    [self showPurposeLabels];
    _emailBtn.titleLabel.textColor = self.view.tintColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
//    UIButton *centerButton = (UIButton*)[self.tabBarController.tabBar viewWithTag:27];
//    [centerButton setEnabled:NO];
}

- (void) showPurposeLabels {
    NSNumber *assessment = [_userPhoto valueForKey:@"Assessment"];
    NSNumber *education = [_userPhoto valueForKey:@"Education"];
    NSNumber *publication = [_userPhoto valueForKey:@"Publication"];
    
    int sum = (assessment.intValue + education.intValue + publication.intValue);
    
    
    switch (sum) {
        case 1:
            [_label1 setHidden:NO];
            [_label2 setHidden:YES];
            [_label3 setHidden:YES];
            if (assessment.intValue == 1)
                [_label1 setText:@"Assessment"];
            else if (education.intValue == 1)
                [_label1 setText:@"Education"];
            else
                [_label1 setText:@"Publication"];

            break;
        case 2:
            [_label1 setHidden:NO];
            [_label2 setHidden:NO];
            [_label3 setHidden:YES];
            if (assessment.intValue == 1) {
                [_label1 setText:@"Assessment"];
                if (education.intValue == 1)
                    [_label2 setText:@"Education"];
                 else
                    [_label2 setText:@"Publication"];
                
                
                
            }
            else if (education.intValue == 1) {
                    [_label1 setText:@"Education"];
                    [_label2 setText:@"Publication"];
                 }
    
            
            break;
        case 3:
            [_label1 setHidden:NO];
            [_label2 setHidden:NO];
            [_label3 setHidden:NO];
            [_label1 setText:@"Assessment"];
            [_label2 setText:@"Education"];
            [_label3 setText:@"Publication"];
            break;
        case 0:
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Complete consent

- (void) savePhoto {
    
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        
        
        [_userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                
                
                PFFile *theImage = [_userPhoto valueForKey:@"imageFile"];
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    PMCloudContentsViewController *vc = (PMCloudContentsViewController*)self.navigationController.viewControllers[0];
                    
                    //save the image to the album
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        UIImage *image = [UIImage imageWithData:data];
                        //UIImage *waterMarkedImg = [self generateWatermarkForImage:image];
                        [self saveImageToAlbum:image withConsent:nil sender:vc];
                        
                    });
                    
                    //check if this viewcontroller is still visible and if so pop to root viewconroller
                    if ([self isEqual:self.navigationController.visibleViewController]) {
                        
                        vc.dataArrayDidChange = @1;
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    
                    
                }];//end of parse getdata
                
            } else
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }];
        
        
    } else {
        
        AlbumContentsViewController *vc = (AlbumContentsViewController*)self.navigationController.viewControllers[0];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Consent *deviceConsent = (Consent*)_userPhoto;
            NSData *imageData = deviceConsent.imageFile;
            UIImage *image = [UIImage imageWithData:imageData];
            [self saveImageToAlbum:image withConsent:deviceConsent sender:vc];
        });
        
    }
    

    
}

- (IBAction)completeAndUpload:(id)sender {
    //add the new object/photo to the allImage array in the cloud Viewcontroller
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        /*
        as it takes a while to save everything we temporarily add the cached image data in the userPhoto object to the cachedImages in PMCLOUDCONTROLLERVIEW class and also add the PFObject (userPhoto) into the allImages array before returning to the rootView Controller leaving the asynchronous tasks to save the data to both the cloud and the album+consent on the device
        */
        PMCloudContentsViewController *vc = (PMCloudContentsViewController*)self.navigationController.viewControllers[0];
        NSCache *cachedImages = [vc cachedImages];
        NSMutableArray *allImages = [vc allImages];
        //get the index as the key by which to add the image to the cache
        NSNumber *nextIndex = [NSNumber numberWithInteger:[vc allImages].count];
        PFFile *imagefile = [_userPhoto valueForKey:@"imageFile"];
        //the image data should be cached within userPhoto but check. If it's not skip and leave it to the asynchronous save processes
        if (imagefile.isDataAvailable) {
            [allImages addObject:_userPhoto];
            NSData* data = [imagefile getData];
            NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
            if (cachedImages.countLimit <= nextIndex.integerValue) {
                [cachedImages setCountLimit:nextIndex.integerValue];
                
            }
            [cachedImages setObject:purgeableData forKey:nextIndex cost:data.length];
            vc.dataArrayDidChange = @1;
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
        }
    }
    
    [self savePhoto]; //if cloud will save to cloud and album
    
}
- (void) saveImageToAlbum:(UIImage*)image withConsent:(Consent*)deviceConsent sender:(id) senderController;  {
    
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
            
            if ([senderController isKindOfClass:[AlbumContentsViewController class]]) {
                [(AlbumContentsViewController*)senderController setDataArrayDidChange:@1];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            } else {
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:@"NotificationDidSaveToAlbum" object:self];
            }
            if (albumAssetURL) {
                if ([_userPhoto isKindOfClass:[PFObject class]]) {
                    
                    [self createDeviceConsentFromPFObjectForAssetAtURL:albumAssetURL];
                   
                }
                else {
                    
                    [deviceConsent setAssetURL:albumAssetURL];
                    [deviceConsent setCreatedAt:[NSDate date]];
                    [self saveDeviceConsent:deviceConsent];

                }
            }
        }
            
    }];
    
    
}

- (void) createDeviceConsentFromPFObjectForAssetAtURL:(NSURL*)newAssetURL {
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        PFFile *theImage = [_userPhoto valueForKey:@"imageFile"];
        if (theImage.isDataAvailable) {
            NSString *reference = [_userPhoto valueForKey:@"referenceID"];
            NSString *patientName = [_userPhoto valueForKey:@"patientName"];
            NSString *patientEmail = [_userPhoto valueForKey:@"patientEmail"];
            
            NSNumber *assessment = [_userPhoto valueForKey:@"Assessment"];
            NSNumber *education = [_userPhoto valueForKey:@"Education"];
            NSNumber *publication = [_userPhoto valueForKey:@"Publication"];
            PFFile *signature = [_userPhoto valueForKey:@"consentSignature"];
            if (signature.isDataAvailable) {
                Consent *deviceConsent = [[Consent alloc] initWithReference:reference imageFile:[theImage getData]];
                deviceConsent.patientName = patientName;
                deviceConsent.patientEmail = patientEmail;
                deviceConsent.Assessment = assessment;
                deviceConsent.Education = education;
                deviceConsent.Publication = publication;
                deviceConsent.consentSignature = [signature getData];
                deviceConsent.assetURL = newAssetURL;
                deviceConsent.createdAt = [NSDate date];
                [self saveDeviceConsent:deviceConsent];
            }
        } else
            return;
    }
    
}

- (void)saveDeviceConsent:(Consent*)deviceConsent {
  
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
        NSData  *signatureData, *imageData;
        [composer setMessageBody:emailBody isHTML:YES];
        if ([_userPhoto isKindOfClass:[PFObject class]]) {
            
            PFFile *imagefile = [_userPhoto valueForKey:@"imageFile"];
            //the image data should be cached within userPhoto but check.
            if (imagefile.isDataAvailable) {
                imageData = [imagefile getData];
            }
            PFFile *signaturefile = [_userPhoto valueForKey:@"consentSignature"];
            if (signaturefile.isDataAvailable) {
                signatureData = [signaturefile getData];
            }

            
            
        } else {
            signatureData = [_userPhoto valueForKey:@"consentSignature"];
            imageData = [_userPhoto valueForKey:@"imageFile"];
        
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
    
    UIImage *watermarkImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    CGImageRelease(mask);
    return watermarkImage;
    
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
