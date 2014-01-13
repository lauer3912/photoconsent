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
    label.text = @"Photoconsent";
    [label sizeToFit];
    self.signUpView.logo = label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
