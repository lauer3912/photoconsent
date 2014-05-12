//
//  PMConsentDetailViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 17/04/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMConsentDetailViewController.h"
#import "PMBasicDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PMTextConstants.h"
#import "PMUsePhotoViewController.h"
#import "PMCameraRollActivity.h"
#import "PMCloudContentsViewController.h"

@interface PMConsentDetailViewController () <UINavigationControllerDelegate>

@end

@implementation PMConsentDetailViewController

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
	[_ib_assessmentSwitch addTarget:self action:@selector(consentSwitchChange:) forControlEvents:UIControlEventValueChanged];
    [_ib_educationSwitch addTarget:self action:@selector(consentSwitchChange:) forControlEvents:UIControlEventValueChanged];
    [_ib_publicationSwitch addTarget:self action:@selector(consentSwitchChange:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [self.navigationController setDelegate:self];
    
}


- (void) consentSwitchChange:(UISwitch*)sender {
    
    if (sender.isOn)
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    else
        if ((_ib_assessmentSwitch.isOn + _ib_educationSwitch.isOn + _ib_publicationSwitch.isOn) > 0) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        } else
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        
        
}

- (void)viewWillAppear:(BOOL)animated
{
   
    [super viewWillAppear:animated];
    // add a border to consent form labels
    _assessmentLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _assessmentLabel.layer.borderWidth = 2.0;
    
    _educationLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _educationLabel.layer.borderWidth = 2.0;
    
    _publicationLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _publicationLabel.layer.borderWidth = 2.0;
    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToBasicDetailsView"]) {
        PMBasicDetailsViewController *vc = (PMBasicDetailsViewController *)segue.destinationViewController;
        vc.userPhoto = sender;
        [vc setConsentDelegate:_consentDelegate];
    }
    
    
}

#pragma mark - IBAction

- (IBAction)onAssessment:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kPMTextConstants_Assessment delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}
- (IBAction)onEducation:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kPMTextConstants_Education delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}
- (IBAction)onPublication:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kPMTextConstants_Publication delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)cancelBtn:(id)sender {
    
    if ([_consentDelegate respondsToSelector:@selector(didCancelConsent)]) {
        [_consentDelegate didCancelConsent];
    }
    
    
}

- (IBAction)pressedNextButton:(UIBarButtonItem *)sender {
    // set consent details for assessment, education and publication and then pass to next VC
    [_userPhoto setValue:[NSNumber numberWithBool:_ib_assessmentSwitch.on] forKey:@"Assessment"];
    [_userPhoto setValue:[NSNumber numberWithBool:_ib_educationSwitch.on] forKey:@"Education"];
    [_userPhoto setValue:[NSNumber numberWithBool:_ib_publicationSwitch.on] forKey:@"Publication"];
    
    [self performSegueWithIdentifier:@"goToBasicDetailsView" sender:_userPhoto];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (viewController.view.tag == 100) {
        id<UIAlertViewDelegate> vc;
        if ([viewController isKindOfClass:[PMUsePhotoViewController class]]) {
            vc = [(PMUsePhotoViewController*)viewController alertViewDelegate];

        } else
            
            if ([navigationController.presentingViewController isKindOfClass:[UIActivityViewController class]]) {
                //this is a cameraRollActivity
                
                //track back to get the alert view delegate
                UIActivityViewController *uac = (UIActivityViewController*)navigationController.presentingViewController;
                
                UINavigationController  *nc = (UINavigationController*)uac.presentingViewController;
                
                vc = (PMCloudContentsViewController*)nc.topViewController;
                
            }
        
        
        [navigationController setNavigationBarHidden:YES];
        [self showReferenceIDWithDelegate:vc];
       
    }
    
}

- (void) showReferenceIDWithDelegate:(id<UIAlertViewDelegate>) avDelegate {
    
    
    UIAlertView *referenceID = [[UIAlertView alloc] initWithTitle:@"Reference Identifier" message:nil delegate:avDelegate cancelButtonTitle:@"Cancel" otherButtonTitles: @"Done",nil];
    referenceID.tag = 2;
    [referenceID setAlertViewStyle:UIAlertViewStylePlainTextInput];
    NSString *reference = [_userPhoto valueForKey:@"referenceID"];
    UITextField *textField = [referenceID textFieldAtIndex:0];
    
    [textField setTextColor:[UIColor blueColor]];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField setText:reference];
    [referenceID show];
    
}

@end
