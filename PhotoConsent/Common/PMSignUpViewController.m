//
//  PMSignUpViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 06/06/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMSignUpViewController.h"
#import "PMLogoLabel.h"

@interface PMSignUpViewController ()

@end

@implementation PMSignUpViewController

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
    
    PMLogoLabel *label = [[PMLogoLabel alloc] init];
    label.text = @"PhotoConsent";
    [label sizeToFit];
    self.signUpView.logo = label;
    
    
    
    [self customiseSignUpAdditionalField];
    
}

- (void)customiseSignUpAdditionalField {
    UITextField *disclaimer = self.signUpView.additionalField;
    
    [disclaimer setTextColor:[UIColor lightTextColor]];
    [disclaimer setFont:[UIFont systemFontOfSize:12.0]];
    [disclaimer setBackgroundColor:[UIColor clearColor]];
    [disclaimer setTextAlignment:NSTextAlignmentCenter];
    [disclaimer setUserInteractionEnabled:NO];
    
    [self checkDisclaimerStatus];
    
}

- (void)checkDisclaimerStatus {
    UITextField *disclaimer = self.signUpView.additionalField;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *disclaimerAcknowledged = [defaults objectForKey:@"disclaimerAcknowledged"];
    if ([disclaimerAcknowledged boolValue] == NO)
        [disclaimer setText:@"Sign up requires acceptance of Disclaimer"];
    else
        [disclaimer setText:@"Disclaimer accepted - Sign up to register"];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self checkDisclaimerStatus];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
