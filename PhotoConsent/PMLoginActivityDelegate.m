//
//  PMLoginActivityDelegate.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 18/01/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMLoginActivityDelegate.h"
#import "PMLoginActivity.h"
#import <Parse/Parse.h>
#import  "BaseViewController.h"



@interface PMLoginActivityDelegate ()
<UIActivityItemSource>
@property (strong, nonatomic) id senderController;
@property (strong, nonatomic) id logActivity;
@end





@implementation PMLoginActivityDelegate

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

#pragma mark UIActivityViewController

- (void)showActivitySheet:(id)sender
{
    
    _senderController = sender;
    
   
    UIActivityViewController *activityViewController;
    
    
    _logActivity = [PMLoginActivity new];
    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_logActivity]];
    
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypePrint];
    
    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
        
        if ([activityType isEqualToString:@"loginActivityType"])
            if ([PFUser currentUser]) {
                if ([_senderController isKindOfClass:[BaseViewController class]]) {
                    BaseViewController* vc = (BaseViewController*)_senderController;
                    [vc centerItemTapped];
                }

            }
    };
    
    activityViewController.completionHandler = completionBlock;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [(UIViewController*)sender presentViewController:activityViewController animated:YES completion:^{
            
        }];
        
    }
    
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return nil;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    
    return nil;
}

@end
