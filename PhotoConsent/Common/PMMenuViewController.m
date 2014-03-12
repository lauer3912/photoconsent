//
//  PMMenuViewController.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 16/02/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMMenuViewController.h"


@interface PMMenuViewController ()

@end

@implementation PMMenuViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Button pressed
- (IBAction)shareAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(shareActivity:)]) {
        [_delegate shareActivity:sender];
    }

}

- (IBAction)showConsentTypes:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(showConsentTypes)]) {
        [_delegate showConsentTypes];
    }
    
}

- (IBAction)showDisclaimer:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(showDisclaimer)]) {
        [_delegate showDisclaimer];
    }
    
}


@end
