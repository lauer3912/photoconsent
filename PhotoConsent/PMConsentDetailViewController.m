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

@interface PMConsentDetailViewController ()

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (IBAction)pressedNextButton:(UIBarButtonItem *)sender {
    // set consent details for assessment, education and publication and then pass to next VC
    [_userPhoto setValue:[NSNumber numberWithBool:_ib_assessmentSwitch.on] forKey:@"Assessment"];
    [_userPhoto setValue:[NSNumber numberWithBool:_ib_educationSwitch.on] forKey:@"Education"];
    [_userPhoto setValue:[NSNumber numberWithBool:_ib_publicationSwitch.on] forKey:@"Publication"];
    
    [self performSegueWithIdentifier:@"goToBasicDetailsView" sender:_userPhoto];
}

@end
