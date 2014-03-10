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
#import "PMDisclaimerActivity.h"


@interface PMActivityDelegate ()
<UIActivityItemSource, PMLogoutActivityProtocol>
@property (strong, nonatomic) id senderController;
@property (strong, nonatomic) UIActivity *feedbackActivity;
@property (strong, nonatomic) UIActivity *cameraRollActivity;
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
    
    UIActivityViewController *activityViewController;
    
    // initialise two custom services
    _feedbackActivity = [PMFeedbackActivity new];
    _cameraRollActivity = [[PMCameraRollActivity alloc] initWithSenderController:_senderController];
   
    
    NSString* messageItem = [self activityViewController:activityViewController itemForActivityType:nil];
    
    //check if sender is album or cloud
    _senderController = sender;
    if ([_senderController isKindOfClass:[PMCloudContentsViewController class]]) {
        PFUser *user = [PFUser currentUser];
        if (user) {
            _logActivity = [PMLogoutActivity new];
            [_logActivity setDelegate:self];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_logActivity,_cameraRollActivity]];
            
        } else {
            _logActivity = [PMLoginActivity new];
            activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:@[_logActivity]];
        }
    } else
        activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageItem] applicationActivities:@[_feedbackActivity]];
    
    NSMutableArray *excludedActivityTypes = [NSMutableArray arrayWithArray:@[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact, UIActivityTypePrint,UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMessage]];
    
    //exclude mail service if they cannot be sent
    if (![MFMailComposeViewController canSendMail])
        [excludedActivityTypes addObject:UIActivityTypeMail];
    
    activityViewController.excludedActivityTypes = excludedActivityTypes;
    
    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
        //completion code here
    };
    
    activityViewController.completionHandler = completionBlock;
    [activityViewController setValue:@"PhotoConsent" forKey:@"subject"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [(UIViewController*)sender presentViewController:activityViewController animated:YES completion:^{
            
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
    
    return @"PhotoConsent";
}


- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    id text = @"Checkout Photoconsent - the secure app for gaining medical consent for patient images";
        
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

#pragma mark - logout activity delegate called on activityDidFinish

- (void) userDidLogout:(id) sender {
    PMCloudContentsViewController *cloudController = (PMCloudContentsViewController*)_senderController;
    [cloudController clearCollectionView];
    
}

@end
