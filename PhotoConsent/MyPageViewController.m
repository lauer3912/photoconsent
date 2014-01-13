/*
     File: MyPageViewController.m
 Abstract: The view controller used for displaying a list of photos.
  Version: 1.1

 Modified version of Apple sample code. 
 
 Modified 18/12/2013 by Alex R.
 
  Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "MyPageViewController.h"
#import "PhotoViewController.h"
#import "PageViewControllerData.h"
#import <Parse/Parse.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PMConsentActivity.h"
#import "PMConsentViewController.h"
#import "Consent.h"
#import "ConsentStore.h"
#import "PMCloudContentsViewController.h"
#import "AlbumContentsViewController.h"
#import "PMTextConstants.h"
#import "PMFunctions.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface MyPageViewController ()
<UIActionSheetDelegate,UIActivityItemSource, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashBtn;
@property (strong, nonatomic) ALAsset *assetToDelete;
@property (strong, nonatomic) UIImage *imageForEmail;

@end

@implementation MyPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _trashBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhotoActionSheet:)];
    
    UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction  target:self action:@selector(openActivitySheet:)];
    
    NSArray *rightBarButtonItems = @[_trashBtn, actionBtn];
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:YES];
    _currentIndex = _startingIndex;
    [self displayViewControllerAtIndex:_currentIndex];
    
}


#pragma mark - datasource

- (void) displayViewControllerAtIndex:(NSInteger)index {
    
    // start by viewing the photo tapped by the user
    PhotoViewController *startingPage = [PhotoViewController photoViewControllerForPageIndex:index];
    if (startingPage != nil)
    {
        
        self.dataSource = self;
        [self setViewControllers:@[startingPage]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:^(BOOL finished) {
                          if (finished) {
                              
                          }
                      }
          ];
         [_trashBtn setEnabled:[self canBeDeleted:index]];
    }

}

#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    _currentIndex = index;
    [_trashBtn setEnabled:[self canBeDeleted:index]];
    
    return [PhotoViewController photoViewControllerForPageIndex:(index - 1)];;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    _currentIndex = index;
    [_trashBtn setEnabled:[self canBeDeleted:index]];
   
    return [PhotoViewController photoViewControllerForPageIndex:(index + 1)];
}

- (BOOL) canBeDeleted:(NSInteger)index {
    
    id obj = [[PageViewControllerData sharedInstance] objectAtIndex:index];
    if ([obj isKindOfClass:[ALAsset class]]) {
        return [(ALAsset*)obj isEditable];
    } else
        return YES;
        
}

#pragma mark -
#pragma mark  Action sheets before delete photo

-(IBAction) deletePhotoActionSheet:(id)sender {
    
    UIActionSheet* sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    sheet.title =  [NSString stringWithFormat:@"This action cannot be undone"];
    sheet.destructiveButtonIndex = [sheet addButtonWithTitle:@"Delete"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:self.tabBarController.tabBar];
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        return;
    } else
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [self deletePhoto:actionSheet];
        }
    
    
}

#pragma mark -
#pragma mark delete photo
- (void)deletePhoto:(UIActionSheet *)sender
{
    id obj = [[PageViewControllerData sharedInstance] objectAtIndex:_currentIndex];
    if ([obj isKindOfClass:[PFObject class]]) {
        
         [(PFObject*)obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         
             if (succeeded) {
                 //remove the object from allImages in the presenting viewController and also the cache
                 [[PageViewControllerData sharedInstance].photoAssets removeObjectAtIndex:_currentIndex];
                 NSCache *cachedImages = [(PMCloudContentsViewController*)self.navigationController.viewControllers[0] cachedImages];
                 [cachedImages removeObjectForKey:[NSNumber numberWithInteger:_currentIndex]];
                 
                 [self displayPrevPhoto];
                
             
             } else {
             
                 NSLog(@"Error = %@", [error.userInfo valueForKey:NSLocalizedDescriptionKey] );
             }
         
         }];
        
    } else if ([obj isKindOfClass:[ALAsset class]]) {
        _assetToDelete = (ALAsset*)obj; // need this as the assetURL returned in the completionblock will be nil if the image is deleted
        
        NSURL* assetToDeleteURL = [_assetToDelete valueForProperty:ALAssetPropertyAssetURL];
        [_assetToDelete setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error != nil) {
                NSLog(@"Error deleting photo");
            } else {
                //PHOTO REMOVED FROM ALBUM so delete the matching device Consent

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                    [[[ConsentStore sharedDeviceConsents] allDeviceConsents] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                       
                        if ([ [(Consent*)obj assetURL] isEqual:assetToDeleteURL]) {
                            [[ConsentStore sharedDeviceConsents] deleteDeviceConsent:obj];
                            [[ConsentStore sharedDeviceConsents] saveChanges];
                            *stop = YES;
                        }
                    }];
                    NSLog(@"deviceConsent count = %d", [[[ConsentStore sharedDeviceConsents] allDeviceConsents] count]);
                }); //end of dispatch
                
            }
                
        }];
        
        [[PageViewControllerData sharedInstance].photoAssets removeObjectAtIndex:_currentIndex];
        [self displayPrevPhoto];
        
       
    }
}

- (void) displayPrevPhoto {
    if ([[PageViewControllerData sharedInstance].photoAssets count] == 0) {
       
        [self.navigationController popToRootViewControllerAnimated:YES];
        [_trashBtn setEnabled:NO];
        _currentIndex = NSNotFound;
        

    } else {
        if (_currentIndex == [[PageViewControllerData sharedInstance].photoAssets count])
            _currentIndex --;
        [self displayViewControllerAtIndex:_currentIndex];
        
    }
        
    
}

#pragma mark UIActivityViewController
- (IBAction)openActivitySheet:(id)sender
{
    PMConsentActivity *consentActivity = [PMConsentActivity new];
    __block  UIActivityViewController *activityViewController;
    
    id consent = [self activityViewController:activityViewController itemForActivityType:@"consentActivity"];
    __block  NSMutableArray *consentActivityItems =  [NSMutableArray arrayWithArray:@[consent]];

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        itemForEmailActivity([self currentObj], @"consentSignature", ^(id emailPhoto) {
            
            [consentActivityItems addObject:emailPhoto];
            [consentActivityItems addObject:[self activityViewController:activityViewController subjectForActivityType:UIActivityTypeMail]];
            [consentActivityItems addObject:[self activityViewController:activityViewController dataTypeIdentifierForActivityType:UIActivityTypeMail]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                itemForEmailActivity([self currentObj], @"imageFile", ^(id emailPhoto) {
                    [consentActivityItems addObject:emailPhoto];
                    [consentActivityItems addObject:kPMTextConstants_Assessment];
                    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:consentActivityItems   applicationActivities:@[consentActivity]];
                    
                    
                    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard, UIActivityTypePrint];
                    
                    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
                        
                        if ([activityType isEqualToString:@"activityConsent"]) {
                            NSLog(@"Consent Activity completion handler has fired");
                        }
                        
                    };
                    
                    activityViewController.completionHandler = completionBlock;
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                            //iPhone, present activity view controller as is
                            [self presentViewController:activityViewController animated:YES completion:nil];
                        }
                        
                    });// end main queue dispatch
                    
                }); //end signature dispatch
            }); // end imageFile dispatch
      });
});
    
    
    
}

-(id) currentObj {
    
    __block id currentObj = [[PageViewControllerData sharedInstance] objectAtIndex:_currentIndex];
    
    if ([currentObj isKindOfClass:[ALAsset class]]) {
        NSURL *currentAssetURL = [(ALAsset*)currentObj valueForProperty:ALAssetPropertyAssetURL];
        NSArray *deviceConsents = [[ConsentStore sharedDeviceConsents] allDeviceConsents];
        [deviceConsents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[Consent class]]) {
                Consent *deviceConsent = (Consent*)obj;
                if ([deviceConsent.assetURL isEqual:currentAssetURL]) {
                    currentObj = deviceConsent;
                    *stop = YES;
                }
                
            }
        }];
    }
    return currentObj;
    
}

void itemForEmailActivity(id currentObj, NSString* key, void (^block)(id emailPhoto)) {
    
    
    if ([currentObj isKindOfClass:[PFObject class]]) {
        PFFile *signImage = [currentObj valueForKey:key];
        [signImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            NSData *lessData;
            if ([key isEqualToString:@"imageFile"]) {
               lessData = UIImageJPEGRepresentation(resizeImage(image, CGSizeMake(320.0, 480.0)), 0.5f);
             //  image = [UIImage imageWithData:lessData];
                block(lessData);
            } else
            
                block(data);
            
        }];
    } else {
    
        if ([currentObj isKindOfClass:[Consent class]]) {
            NSData *signatureData = [currentObj valueForKey:key];
            block(signatureData);
        }
        
        
    }
    
}


#pragma mark UIActivityItemSource protocol methods
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
   return @"Placeholder";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {

    id currentObj = [self currentObj];
    return [NSString stringWithFormat:@"Reference ID:%@\n\n%@\n\n%@\n\n%@", [currentObj valueForKey:@"referenceID"],kPMTextConstants_Assessment,kPMTextConstants_Education,kPMTextConstants_Publication];
    
    
    
}


- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    id value;
    
    if ([activityType isEqualToString:@"consentActivity"]) {
        
        value = [self currentObj];
    }
    
    return value;
   
    
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
