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
#import "PMConsentActivity.h"
#import "PMConsentViewController.h"
#import "Consent.h"
#import "ConsentStore.h"
#import "PMCloudContentsViewController.h"
#import "PMTextConstants.h"
#import "PMFunctions.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PMFeedbackActivity.h"




@interface MyPageViewController ()
<UIActionSheetDelegate,UIActivityItemSource>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashBtn;
@property (strong, nonatomic) Consent *consentToDelete;
@property (strong, nonatomic) UIImage *imageForEmail;

@property (strong, nonatomic) PMFeedbackActivity *shareActivity;

@end

@implementation MyPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _trashBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhotoActionSheet:)];
    
    UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction  target:self action:@selector(openActivitySheet:)];
    
    NSArray *rightBarButtonItems = @[actionBtn, _trashBtn];
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:YES];
    _currentIndex = _startingIndex;
    [self displayViewControllerAtIndex:_currentIndex];
    
    
}


-(void) flagAssetRemoved {
    
    UIViewController *senderController = self.navigationController.viewControllers[0];
    [senderController setValue:@1 forKey:@"dataArrayDidChange"];

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
        
        //start in background to cache the before and after image data
        int indexMax = ([PageViewControllerData sharedInstance].photoCount - 1);
        if (!(_isSaving && (indexMax - index) == 1)) {
            //possible that the indexmax includes a photo being saved so don't cache if isSaving is true and the selected image index is only 1 less than the indexmax i.e. next to the image being saved
            
            if (index < indexMax) {
                [self cacheDataInBackgroundForPhotoAtIndex:index + 1];

            }
        }
        if (index > 0) {
            [self cacheDataInBackgroundForPhotoAtIndex:index - 1];
        }
        

        
    }

}

#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    _currentIndex = index;
    
    if (index == 0) {
        return nil;
    } else {
        index--;
       
        [_trashBtn setEnabled:[self canBeDeleted:index]];
        
//         NSLog(@"VC BEFORE - RETURNED FOR INDEX = %d CURRENTINDEX = %d", index, _currentIndex);
//        NSLog(@"Count in photoAssets = %d", [[PageViewControllerData sharedInstance] photoCount]);
        
        //test -load in the background the 2 previous photos to the Parse data cache
        [self cacheDataInBackgroundForPhotoAtIndex:index];
        if (index > 0) {
            [self cacheDataInBackgroundForPhotoAtIndex:index - 1];
        }
        
        
        return [PhotoViewController photoViewControllerForPageIndex:(index)];
    }
    
    

}

- (void) cacheDataInBackgroundForPhotoAtIndex:(NSUInteger)index {
    
    id photo = [[PageViewControllerData sharedInstance] objectAtIndex:index];
    if ([photo isKindOfClass:[PFObject class]]) {
        NSString *key = @"imageFile";
        
        PFFile *imageData = [photo objectForKey:key];
        if (!imageData.isDataAvailable) {
            [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSLog(@"Data returned from getDataInBackground for INDEX = %d", index);
            }];
        }
        
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    _currentIndex = index;
    
    int indexMax = ([PageViewControllerData sharedInstance].photoCount - 1);
    if (index == indexMax) {
        return nil;
    } else {
        index ++;
        [_trashBtn setEnabled:[self canBeDeleted:index]];
        
//         NSLog(@"VC AFTER - RETURNED FOR INDEX = %d CURRENTINDEX = %d", index, _currentIndex);
        
//        NSLog(@"Count in photoAssets = %d", [[PageViewControllerData sharedInstance] photoCount]);
        
        
        //test -load in the background the 2 following photos to the Parse data cache
        [self cacheDataInBackgroundForPhotoAtIndex:index];
        //check the second image after is not being saved
        if (!(_isSaving && (indexMax - index) == 1)) {
            if (index < indexMax) {
                 [self cacheDataInBackgroundForPhotoAtIndex:index + 1];
            }
           
        }
        
        
        return [PhotoViewController photoViewControllerForPageIndex:(index)];
    }
    
}

- (BOOL) canBeDeleted:(NSInteger)index {
   
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
    [sheet showInView:self.navigationController.topViewController.view];
    
    
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
    id selectedObject = [[PageViewControllerData sharedInstance] objectAtIndex:_currentIndex];
    
    if ([selectedObject isKindOfClass:[PFObject class]]) {
        
         [(PFObject*)selectedObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         
             if (succeeded) {
                 //remove the object from allImages in the presenting viewController and also the cache
                 
                [self flagAssetRemoved];
                [self displayPrevPhoto];
               
                
             
             } else {
             
                 NSLog(@"Error = %@", [error.userInfo valueForKey:NSLocalizedDescriptionKey] );
             }
         
         }];
    
    } else if ([selectedObject isKindOfClass:[Consent class]]) {
        
        
            [[ConsentStore sharedDeviceConsents] deleteDeviceConsent:selectedObject];
            [[ConsentStore sharedDeviceConsents] saveChanges];
            [self flagAssetRemoved];
        
           [self displayPrevPhoto];
    }
}

 
- (void) displayPrevPhoto {
    
    [[PageViewControllerData sharedInstance].photoAssets removeObjectAtIndex:_currentIndex];
    
    if ([[PageViewControllerData sharedInstance] photoCount] == 0) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        _currentIndex = NSNotFound;
        
        
    } else {
        
        if (_currentIndex == [[PageViewControllerData sharedInstance].photoAssets count])
            _currentIndex --;
    
        NSArray* photoViewControllers = @[ [PhotoViewController photoViewControllerForPageIndex:_currentIndex]];
        
        [self setViewControllers:photoViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
        
    }
    
}


#pragma mark UIActivityViewController
- (IBAction)openActivitySheet:(id)sender
{
   
    
    PMConsentActivity *consentActivity = [PMConsentActivity new];
    __block  UIActivityViewController *activityViewController;
    
    id currentObj = [self currentObj];
  
    __block  NSMutableArray *shareActivityItems =  [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id consent = [self activityViewController:activityViewController itemForActivityType:@"consentActivityType"];
        [shareActivityItems addObject:consent];
        
        _shareActivity = [[PMFeedbackActivity alloc] initWithSenderController:self shareActivityType:shareActivityTypeWithImages];
        
        imageDataForEmailActivity(currentObj, @"consentSignature", ^(id emailPhoto) {
            if (emailPhoto) {
                
                [shareActivityItems addObject:emailPhoto];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                imageDataForEmailActivity([self currentObj], @"imageFile", ^(id emailPhoto) {
                    [shareActivityItems addObject:emailPhoto];
                    
                    
                    [shareActivityItems addObject:[self activityViewController:activityViewController itemForActivityType:@"CustomMailActivityType"]];
                    
                    
                    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareActivityItems  applicationActivities:@[_shareActivity,consentActivity]];
 
                    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeMessage, UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMail];
                    
                    
                    //set up the completion handler but not used
                    UIActivityViewControllerCompletionHandler completionBlock = ^(NSString *activityType, BOOL completed) {
                        
                        if ([activityType isEqualToString:@"CustomMailActivityType"]) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                        
                        [self.view setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
                       
                        
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
    
    id currentObj = [[PageViewControllerData sharedInstance] objectAtIndex:_currentIndex];
    
    return currentObj;
    
}



void imageDataForEmailActivity(id currentObj, NSString* key, void (^block)(id emailPhoto)) {
    
    if ([currentObj isKindOfClass:[PFObject class]]) {
        PFFile *signImage = [currentObj valueForKey:key];
        [signImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            NSData *lessData;
            if ([key isEqualToString:@"imageFile"]) {
               lessData = UIImageJPEGRepresentation(resizeImage(image, CGSizeMake(320.0, 480.0)), 0.5f);
                block(lessData);
            } else
                block(data);
            
        }];
    } else
    
        if ([currentObj isKindOfClass:[Consent class]]) {
            NSData *signatureData = [currentObj valueForKey:key];
            block(signatureData);
        }
        
        
}


#pragma mark UIActivityItemSource protocol methods

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
    return nil;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    
        return nil;
  
    
}


- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    __block id value;
    

    if ([activityType isEqualToString:@"CustomMailActivityType"])
        value = [NSString stringWithFormat:@"Reference:%@", [[self currentObj] valueForKey:@"referenceID"]];
    
    
    
    if ([activityType isEqualToString:@"consentActivityType"])
        value = [self currentObj];
       
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
