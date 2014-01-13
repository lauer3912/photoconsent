//
//  PMPurposeViewController.m
//  Photoconsent
//
//  Created by Alex Rafferty on 06/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMPurposeViewController.h"
#import "PMTextConstants.h"


@interface PMPurposeViewController () 
- (IBAction)closePurposeForm:(id)sender;
@end


@implementation PMPurposeViewController


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
    
    switch (_purpose) {
        case 0:
            [self.textview setText:kPMTextConstants_Assessment];
            [self.navItem setTitle:@"Assessment"];
            break;
        case 1:
            [self.textview setText:kPMTextConstants_Education];
            [self.navItem setTitle:@"Education"];
            break;
        case 2:
            [self.textview setText:kPMTextConstants_Publication];
            [self.navItem setTitle:@"Publication"];
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closePurposeForm:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
