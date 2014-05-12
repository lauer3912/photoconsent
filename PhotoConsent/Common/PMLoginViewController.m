//
//  PMLoginViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 06/06/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMLoginViewController.h"
#import "PMLogoLabel.h"
#import <Parse/Parse.h>

@interface PMLoginViewController ()

@end

@implementation PMLoginViewController

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
	
    // set the login label
    PMLogoLabel *label = [[PMLogoLabel alloc] init];
    label.text = @"PhotoConsent";
    [label sizeToFit];
    self.logInView.logo = label;
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
