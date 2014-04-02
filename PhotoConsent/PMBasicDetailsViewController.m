//
//  PMBasicDetailsViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 27/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMBasicDetailsViewController.h"
#import "PMSignViewController.h"

@interface PMBasicDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameInputField;
@property (weak, nonatomic) IBOutlet UITextField *emailInputField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@implementation PMBasicDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // make the name field the first responder
    [self.nameInputField  becomeFirstResponder];
    
    // set the delegate for the text field
    self.nameInputField.delegate = self;
    self.emailInputField.delegate = self;
    
}



#pragma mark - Actions

- (IBAction)pressedNextButton:(id)sender {
    // first check that somethings has been entered into the required name and email field
    if (self.nameInputField.text.length > 0 && self.emailInputField.text.length > 0) {
        // update the photo model to include this basic information
        [_userPhoto setValue:self.nameInputField.text forKey:@"patientName"];
        [_userPhoto setValue:self.emailInputField.text forKey:@"patientEmail"];
        
        // transition to the signing VC
        [self performSegueWithIdentifier:@"goToSignView" sender:nil];
    } else {
        // show an error message to let the patient know they need to complete this information
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your name and email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToSignView"]) {
        // pass on the photo object to the next view
        PMSignViewController *controller = segue.destinationViewController;
        controller.userPhoto = _userPhoto;
    }
}

@end
