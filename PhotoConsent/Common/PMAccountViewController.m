//
//  PMAccountViewController.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 26/01/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMAccountViewController.h"
#import <Parse/Parse.h>


@interface PMAccountViewController ()

@property (weak,nonatomic) IBOutlet UILabel* nameLabel;
@property (weak,nonatomic) IBOutlet UILabel* sessionLabel;
@property (weak,nonatomic) IBOutlet UILabel* disclaimerLabel;


@end

@implementation PMAccountViewController

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
    
    [_nameLabel setText:[PFUser currentUser].username];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [_sessionLabel setText:[defaults valueForKey:@"lastAppSession"]];
    [_disclaimerLabel setText:[defaults valueForKey:@"disclaimerAcknowledgedDate"] ];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeActivity:(id)sender {
    
    [_activity activityDidFinish:YES];
    
    
}

@end
