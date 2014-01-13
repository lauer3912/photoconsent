//
//  PMActivityDelegate.m
//  Photoconsent
//
//  Created by Alex Rafferty on 09/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMActivityDelegate.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PMConsentActivity.h"
#import "PMFeedbackActivity.h"
#import "PMLogoutActivity.h"
#import "PMCameraRollActivity.h"
#import "PMConsentDetailsActivity.h"
#import "PMLoginActivity.h"
#import <Parse/Parse.h>
#import "PMCloudContentsViewController.h"


@interface PMActivityDelegate ()
<UIActivityItemSource, PMLogoutActivityProtocol>
@property (strong, nonatomic) id senderController;
@property (strong, nonatomic) UIActivity *feedbackActivity;
@property (strong, nonatomic) UIActivity *cameraRollActivity;
@property (strong, nonatomic) id logActivity;

@property (strong, nonatomic) UIActivity *consentDetailsActivity;


@end

@implementation PMActivityDelegate

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
    
    _feedbackActivity = [PMFeedbackActivity new];
   
    _cameraRollActivity = [[PMCameraRollActivity alloc] initWithSenderController:_senderController];
    
    _consentDetailsActivity = [PMConsentDetailsActivity new];
    // set the logged in user's email to show at the top
    
    UIActivityViewController *activityViewController;
    
    if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
        PFUser *user = [PFUser currentUser];
        if (user) {
            _logActivity = [PMLogoutActivity new];
            [_logActivity setDelegate:self];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_feedbackActivity,_logActivity,_cameraRollActivity,_consentDetailsActivity]];
            
        } else {
            _logActivity = [PMLoginActivity new];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_feedbackActivity,_logActivity,_consentDetailsActivity]];
        }
    } else
        activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_feedbackActivity,_consentDetailsActivity]];
    
    
    
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypePrint];
    
    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
        
        if ([activityType isEqualToString:@"feedbackActivityType"]) {
            NSLog(@"completion block did run for feedBackActivity");
        }
        
    };
    
    activityViewController.completionHandler = completionBlock;
    
    [self activityViewControllerPlaceholderItem:activityViewController];
    
    [self activityViewController:activityViewController subjectForActivityType:UIActivityTypeMail];
    
    [self activityViewController:activityViewController itemForActivityType:UIActivityTypeMail];
    [self activityViewController:activityViewController itemForActivityType:UIActivityTypePostToFacebook];
    [self activityViewController:activityViewController itemForActivityType:UIActivityTypePostToTwitter];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [(UIViewController*)sender presentViewController:activityViewController animated:YES completion:^{
            
        }];

    }
    
}


#pragma mark UIActivityItemSource protocol methods
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
    return @"Placeholder";
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
    
    return nil;
}


- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    
    if ([activityType isEqualToString:UIActivityTypeMail])
       return @"Subject string returned";
    else
        return @"No subject";
     
}


- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    
    id string;
    if ([activityType isEqualToString:UIActivityTypeMail])
        string = @"Mailing news about Photoconsent - the secure app for gaining medical consent for patient images";
    else if ([activityType isEqualToString:UIActivityTypePostToFacebook])
        string =  @"Checkout Photoconsent - the secure app for gaining medical consent for patient images";
    else if ([activityType isEqualToString:UIActivityTypePostToTwitter])
        string = @"Checkout Photoconsent - the secure app for gaining medical consent for patient images";
    
    return string;
    
    
    
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType {
    // works fine without this but better safe than sorry
    NSString *value;
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        
        CFStringRef UTI = kUTTypeJPEG;
        value = (__bridge NSString *)(UTI);
    }
    
    return value;
}
#pragma mark - logout activity delegate called on activityDidFinish

- (void) userDidLogout:(id) sender {
    PMCloudContentsViewController *cloudController = (PMCloudContentsViewController*)_senderController;
    [cloudController clearCollectionView];
    
}

@end
