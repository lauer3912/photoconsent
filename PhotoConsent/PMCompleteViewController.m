//
//  PMCompleteViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 28/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMCompleteViewController.h"
#import "Consent.h"
#import "PMFunctions.h"
#import "ConsentStore.h"
#import "PMTextConstants.h"
#import "PMCloudContentsViewController.h"
#import  <Parse/Parse.h>
#import "UIColor+More.h"



@interface PMCompleteViewController () <UIAlertViewDelegate>

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
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        PFFile *imagefile = [_userPhoto valueForKey:@"imageFile"];
        //the image data should be cached within userPhoto but check. If it's not skip and leave it to the asynchronous save processes
        if (imagefile.isDataAvailable) {
            if (isPaid()) {
                _imageView.image = [UIImage imageWithData:[imagefile getData]];
            } else
                _imageView.image =  generateWatermarkForImage([UIImage imageWithData:[imagefile getData]]);
        }
    }
    [self showPurposeLabels];
    
    [self.view setBackgroundColor:[UIColor turquoise]];
    
    _emailBtn.titleLabel.textColor = [UIColor turquoise];
    
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
            if (succeeded) {
                
                
                PFFile *theImage = [_userPhoto valueForKey:@"imageFile"];
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    PMCloudContentsViewController *vc = (PMCloudContentsViewController*)self.navigationController.viewControllers[0];
                    
                    //save copy of image and consent on the device
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         [self createDeviceConsentFromPFObject];
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
        
        
    }
    
}

- (IBAction)completeAndUpload:(id)sender {
    //NOTE will always be PFObject. add the new object/photo to the allImage array in the cloud Viewcontroller
    if ([_userPhoto isKindOfClass:[PFObject class]]) {
        /*
        as it takes a while to save everything we temporarily add the cached image data in the userPhoto object to the cachedImages in PMCLOUDCONTROLLERVIEW class and also add the PFObject (userPhoto) into the allImages array before returning to the rootView Controller leaving the asynchronous tasks to save the data to both the cloud and the device
        */
        PMCloudContentsViewController *vc = (PMCloudContentsViewController*)self.navigationController.viewControllers[0];
        NSCache *cachedSmallImages = [vc cachedSmallImages];
        NSCache *cachedLargeImages = [vc cachedLargeImages];
        NSMutableArray *allImages = [vc allImages];
        //get the index as the key by which to add the image to the cache
        NSNumber *nextIndex = [NSNumber numberWithInteger:[vc allImages].count];
        PFFile *largeImageData = [_userPhoto valueForKey:@"imageFile"];
        PFFile *smallImageData = [_userPhoto valueForKey:@"smallImageFile"];
        //the image data should be cached within userPhoto but check. If it's not skip and leave it to the asynchronous save processes
        if (largeImageData.isDataAvailable) {
            [allImages addObject:_userPhoto];
            NSData* data = [largeImageData getData];
            NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
            [cachedLargeImages setObject:purgeableData forKey:nextIndex cost:data.length];
            vc.dataArrayDidChange = @1;
            vc.shouldDim = NO;
            [vc.navigationItem.rightBarButtonItem setEnabled:NO];//Gets re-enabled in PMCloudContentsViewController viewDidAppear
            if (smallImageData.isDataAvailable) {
                NSData* data = [smallImageData getData];
                NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                [cachedSmallImages setObject:purgeableData forKey:nextIndex cost:data.length];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
            
        }
        [self savePhoto];
    }
    
    
}

- (void) createDeviceConsentFromPFObject {
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
                deviceConsent.assetURL = nil;
                deviceConsent.createdAt = [NSDate date];
                [self saveDeviceConsent:deviceConsent];
            }
        } else
            return;
    }
    
}

//not used
- (void)showCameraRollAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *message = [NSString stringWithFormat:@"The photo and its consent details have been saved. The original remains in the Camera Roll"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copy Complete" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self dismiss:alert];
            
        });
    });
}

- (void)saveDeviceConsent:(Consent*)deviceConsent {
  
    ConsentStore *store = [ConsentStore sharedDeviceConsents];
    [store addDeviceConsent:deviceConsent];
    if ([store saveChanges]) {
        //if camera roll - showCameraRollAlert
    }
    
}

-(void)dismiss:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
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
        
        
        [composer.navigationBar setTintColor:[UIColor turquoise]];
        // set the recipient as the patient
        NSArray *recipients = [[NSArray alloc] initWithObjects:[_userPhoto valueForKey:@"patientEmail"], nil];
        [composer setToRecipients:recipients];
        
        // set the subject
        [composer setSubject:@"PhotoConsent Image"];
        
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
                //add the watermark
                UIImage *image;
                if (isPaid()) {
                    image = [UIImage imageWithData:[imagefile getData]];
                } else
                    image =  generateWatermarkForImage([UIImage imageWithData:[imagefile getData]]);
                
               imageData = UIImageJPEGRepresentation(image, 1.0f);
                
            }
            PFFile *signaturefile = [_userPhoto valueForKey:@"consentSignature"];
            if (signaturefile.isDataAvailable) {
                signatureData = [signaturefile getData];
            }

            
            
        } else { //offline
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


@end







