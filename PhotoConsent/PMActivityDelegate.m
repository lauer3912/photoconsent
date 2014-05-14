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
#import "PMRefreshActivity.h"
#import "PMCameraRollActivity.h"
#import "PMConsentDetailsActivity.h"
#import "PMLoginActivity.h"
#import <Parse/Parse.h>
#import "PMCloudContentsViewController.h"
#import "PMWorkOfflineActivity.h"
#import "ConsentStore.h"


@interface PMActivityDelegate ()
<UIActivityItemSource>

@property (strong, nonatomic) PMFeedbackActivity *feedbackActivity;
@property (strong, nonatomic) PMFeedbackActivity *shareActivity;
@property (strong, nonatomic) PMCameraRollActivity *cameraRollActivity;
@property (strong, nonatomic) PMRefreshActivity *refreshActivity;
@property (strong, nonatomic) PMWorkOfflineActivity *offlineActivity;
@property (strong, nonatomic) id logActivity;


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
   
    //this uses UIActivityController to provide sharing services - but as at iOS7 still some issues when relying solely on the system controller
    
    NSMutableArray *excludedActivityTypes = [NSMutableArray arrayWithCapacity:10];
    
    UIActivityViewController *activityViewController;
    
    
    if ([MFMailComposeViewController canSendMail]) {
        
        _feedbackActivity = [[PMFeedbackActivity alloc] initWithSenderController:_senderController shareActivityType:shareActivityTypeFeedback];
        _shareActivity = [[PMFeedbackActivity alloc] initWithSenderController:_senderController shareActivityType:shareActivityTypePromote];
    }

    _cameraRollActivity = [[PMCameraRollActivity alloc] init];
    [_cameraRollActivity setConsentDelegate:_consentDelegate];
    [_cameraRollActivity setSenderController:_senderController];
    [_cameraRollActivity setAlertViewDelegate:_alertviewDelegate];
   
    
    
     NSString* messageItem = [self activityViewController:activityViewController itemForActivityType:nil];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        PFUser *user = [PFUser currentUser];
        if (user) {
            _logActivity = [PMLogoutActivity new];
            [_logActivity setDelegate:_senderController];
            
            _refreshActivity = [[PMRefreshActivity alloc] init];
            [_refreshActivity setRefreshDelegate:_senderController];
            [_refreshActivity setIsSaving:_isSaving];
            
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_logActivity,_cameraRollActivity,_refreshActivity]];
            
            
            
            
        } else {
            //login to cloud or start/stop offline working on device
            
            _logActivity = [PMLoginActivity new];
            [_logActivity setStopOfflineDelegate:_senderController];
            [_logActivity setRefreshDelegate:_senderController];
            
            NSInteger  countDeviceImages = [[[ConsentStore sharedDeviceConsents] allDeviceConsents] count];
            NSNumber *imageCount = [NSNumber numberWithInteger:countDeviceImages];
            NSString *nameForActivity = @"View";
            _offlineActivity = [PMWorkOfflineActivity new];
            [_offlineActivity setOfflineDelegate:_senderController];
            
            
            if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
                PMCloudContentsViewController* controller = (PMCloudContentsViewController*)_senderController;
                if (controller.allImages) {
                    
                       nameForActivity = @"Hide";
                } 
                
            }
            
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[imageCount,nameForActivity] applicationActivities:@[_logActivity,_offlineActivity]];
        }
    } else
        activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageItem] applicationActivities:@[_shareActivity, _feedbackActivity]];
    
    [excludedActivityTypes addObjectsFromArray:@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypePrint,UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMessage,UIActivityTypeAirDrop,UIActivityTypeMail]];
    
   
    
    activityViewController.excludedActivityTypes = excludedActivityTypes;
    
    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
        if ([activityType isEqualToString:@"CustomMailActivityType"]) {
          [(UIViewController*)_senderController dismissViewControllerAnimated:YES completion:nil];
        }
        
        
    };
    
    activityViewController.completionHandler = completionBlock;
   
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [(UIViewController*)_senderController presentViewController:activityViewController animated:YES completion:^{
           
        }];

    }
    
}


#pragma mark UIActivityItemSource protocol methods


- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
    return nil;
}


- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
    
    return nil;
}


- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    
    return @"PhotoConsent is good";
}


- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    id text = @"Checkout PhotoConsent - the secure app for gaining medical consent for patient images";
        
    return text;
    
    
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


@end
