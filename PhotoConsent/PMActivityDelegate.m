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
#import "PMMessageActivity.h"
#import "PMSubjectProvider.h"
#import "PMDisclaimerActivity.h"
#import "PMAccountActivity.h"


@interface PMActivityDelegate ()
<UIActivityItemSource, PMLogoutActivityProtocol>
@property (strong, nonatomic) id senderController;
@property (strong, nonatomic) UIActivity *feedbackActivity;
@property (strong, nonatomic) UIActivity *disclaimerActivity;
@property (strong, nonatomic) UIActivity *messageActivity;
@property (strong, nonatomic) UIActivity *accountActivity;
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
    UIActivityViewController *activityViewController;
    _senderController = sender;
    
    _feedbackActivity = [PMFeedbackActivity new];
    _disclaimerActivity = [PMDisclaimerActivity new];
    _cameraRollActivity = [[PMCameraRollActivity alloc] initWithSenderController:_senderController];
    _accountActivity = [PMAccountActivity new];
    _consentDetailsActivity = [PMConsentDetailsActivity new];
   
    NSString *subject = [self activityViewController:activityViewController subjectForActivityType:UIActivityTypeMail];
    
    NSString* messageItem = [self activityViewController:activityViewController itemForActivityType:UIActivityTypeMessage];
    
    
    if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
        PFUser *user = [PFUser currentUser];
        if (user) {
            _logActivity = [PMLogoutActivity new];
            [_logActivity setDelegate:self];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageItem] applicationActivities:@[_feedbackActivity, _logActivity,_cameraRollActivity,_consentDetailsActivity,_disclaimerActivity,_accountActivity]];
            
        } else {
            _logActivity = [PMLoginActivity new];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageItem] applicationActivities:@[_feedbackActivity,  _logActivity,_consentDetailsActivity,_disclaimerActivity, _accountActivity]];
        }
    } else
        activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageItem] applicationActivities:@[_feedbackActivity, _consentDetailsActivity,_disclaimerActivity,_accountActivity]];
    
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypePrint];
    
    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
        
        if ([activityType isEqualToString:UIActivityTypeMail]) {
            NSLog(@"UIActivityTypeMail completion block shows subject was %@", subject);
        }
        
    };
    
    activityViewController.completionHandler = completionBlock;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [(UIViewController*)sender presentViewController:activityViewController animated:YES completion:^{
            
        }];

    }
    
}


#pragma mark UIActivityItemSource protocol methods


- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
    return @"";
}


- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
    
    return nil;
}


- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    
    if ([activityType isEqualToString:UIActivityTypeMail])
       return @"PhotoConsent v2.0";
    else
        return @"";
     
}


- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    
    id string;
    if ([activityType isEqualToString:UIActivityTypeMessage])
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
