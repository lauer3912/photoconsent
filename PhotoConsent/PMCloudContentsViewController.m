//
//
//  PMCloudContentsViewController.m
//  Photoconsent
//
//  Created by Alex Rafferty on 18/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//  

#import "PMCloudContentsViewController.h"
#import  <iAd/iAd.h>
#import "MyPageViewController.h"
#import "PMLoginViewController.h"
#import "PMSignUpViewController.h"
#import "PageViewControllerData.h"
#import "PMCompleteViewController.h"
#import "PMConsentDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PMActivityDelegate.h"
#import "PMMenuViewController.h"
#import "TLTransitionAnimator.h"
#import "PMCameraDelegate.h"
#import "PMLoginActivityDelegate.h"
#import "Consent.h"
#import "ConsentStore.h"
#import "PMWorkOfflineActivity.h"
#import "PMLogoutActivity.h"
#import "PMLoginActivity.h"
#import "PMUpgradeViewController.h"
#import "PMFunctions.h"

@interface PMCloudContentsViewController () <shareActivityProtocol,PMWorkOfflineActivityProtocol,PMLogoutActivityProtocol, PMWStopOfflineActivityProtocol>

@property (strong, nonatomic)  UILabel *emptyLabel;

@property (strong, nonatomic) PMActivityDelegate* delegateInstance;
@property (strong, nonatomic) PMCameraDelegate* cameraDelegateInstance;
@property (strong, nonatomic) PMLoginActivityDelegate* loginActivityDelegate;

@end

@implementation PMCloudContentsViewController
{
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setCanDisplayBannerAds:!isPaid()];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _allImages = [[NSMutableArray alloc] init];
    [self setCanDisplayBannerAds:!isPaid()];
    NSLog(@"There are %lu images stored offline on the device", (unsigned long)[[ConsentStore sharedDeviceConsents] allDeviceConsents].count);
    
    _dataArrayDidChange = @0;
    
    if ([PFUser currentUser]) {
        [self loadAndCacheObjects];
        [self titleViewWithEnableSwitch:YES];
    } else
        [self titleViewWithEnableSwitch:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser]) {
        if (!_allImages) {
            _allImages = [[NSMutableArray alloc] init];
            [self loadAndCacheObjects];
            
            
        } else {
            if (_dataArrayDidChange.boolValue == YES) {
                [self.collectionView reloadData];
                _dataArrayDidChange = @0; //= NO
            }
            [self showEmptyLabel];
        }
    } else  {
        if (_allImages.count == 0) {
            [self userDidLogout:nil];
        }
        if (_dataArrayDidChange.boolValue == YES) {
            [self.collectionView reloadData];
            _dataArrayDidChange = @0; //= NO
        }
        [self showEmptyLabel];
    }

    
}


- (UIView*)titleViewWithEnableSwitch:(BOOL)shouldEnable  {
    
    self.navigationItem.titleView = nil;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120., 44.0)];
    
    if (shouldEnable) {
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"714-camera"];
        
        [cameraBtn setImage:image forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(useCamera:) forControlEvents:UIControlEventTouchUpInside];
        cameraBtn.frame = CGRectMake(40.0, 0.0, 40., 40.);
        [cameraBtn setEnabled:shouldEnable];
        [titleView addSubview:cameraBtn];
    } else {
        UILabel *offlineLabel = [[UILabel alloc] initWithFrame:titleView.bounds];
        [offlineLabel setBackgroundColor:[UIColor clearColor]];
        [offlineLabel setTextAlignment:NSTextAlignmentCenter];
        [offlineLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
        [offlineLabel setTextColor:[UIColor darkTextColor]];
        if (_allImages.count > 0)
            [offlineLabel setText:@"Offline"];
        else
            [offlineLabel setText:@"PhotoConsent"];
        
        [titleView addSubview:offlineLabel];
    }
    return titleView;
}

- (IBAction)useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera] == YES){
        
        
        
        if (![PFUser currentUser]) {
            if (!_loginActivityDelegate)
                _loginActivityDelegate = [[PMLoginActivityDelegate alloc] init];
            
            
            _activityDelegate = _loginActivityDelegate;
            
            if ([_activityDelegate respondsToSelector:@selector(showActivitySheet:)])
                [_activityDelegate showActivitySheet:self];
            
        }
            
        
        if (!_cameraDelegateInstance) {
            _cameraDelegateInstance = [[PMCameraDelegate alloc] init];
        }
        _cameraDelegate = _cameraDelegateInstance;
        
        if ([_cameraDelegate respondsToSelector:@selector(startCamera:)]) {
            //determine the currently selected tab on tabbar. If user is scrolling through individual photos pop back to root viewcontroller before sending the viewcontroller to the camera delegate
            
            UINavigationController *navController = (UINavigationController*)self.navigationController;
            
            if ([navController.topViewController isKindOfClass:[MyPageViewController class]]) {
                [navController popToRootViewControllerAnimated:NO];
            }
            
            
            [_cameraDelegate startCamera:navController.topViewController];
            
            
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry but this device does not have a camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void) showEmptyLabel {
    if (refreshHUD) {
        if (_emptyLabel) {
            [_emptyLabel removeFromSuperview];
        }
        return;
    }
    
    if (_allImages) {
        
        if (_allImages.count == 0) {
            if (!_emptyLabel) {
                _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
                _emptyLabel.backgroundColor = [UIColor clearColor];
                [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
            }
            
            if ([PFUser currentUser]) {
                [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:YES]];
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"No photos to display"]]];
            } else
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are not logged in"]]];
            
            [self.view addSubview:_emptyLabel];
            
        } else {
            if (_emptyLabel) {
                [_emptyLabel removeFromSuperview];
                _emptyLabel = nil;
            }
            
            if ([PFUser currentUser])
              [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:YES]];
            else
              [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:NO]];
        }
    } else
        //if not logged in
        if (![PFUser currentUser]) {
            [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:NO]];
            if (_emptyLabel) {
                [_emptyLabel removeFromSuperview];
            }
            if (!_emptyLabel) {
                _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
                _emptyLabel.backgroundColor = self.collectionView.backgroundColor;
                [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
            }
            
            [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are not logged in"]]];
            [self.view addSubview:_emptyLabel];
        }
    
}

#pragma mark - create image cache for cloud or device images and reload

//delegate to PMWorkOfflineActivity
- (void) loadAndCacheDeviceImages:(id) sender {
    
        NSArray *allPhotos = [NSArray arrayWithArray:[[ConsentStore sharedDeviceConsents] allDeviceConsents]];
        _allImages = nil;
        _allImages = [NSMutableArray arrayWithCapacity:allPhotos.count];
        [self cacheImages:allPhotos];
    
}

- (void) cacheImages:(NSArray*) allPhotos {
    
    if (allPhotos.count == 0) {
        return;
    }

    [self showHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_cachedImages) {
            _cachedImages = [NSCache new];
        }
        

        [_cachedImages setName:@"imageCache"];
        [_cachedImages setTotalCostLimit:(5 * 1024 * 1024)];//5MB
        [_cachedImages setEvictsObjectsWithDiscardedContent:YES];
        
        [allPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[PFObject class]]) {
                PFFile *theImage = [(PFObject*)obj objectForKey:@"smallImageFile"];
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    
                    NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                    
                    NSNumber *index = [NSNumber numberWithInteger:idx];
                    [_cachedImages setObject:purgeableData forKey:index cost:data.length];
                    
                }];
            } else if ([obj isKindOfClass:[Consent class]]) {
                [_allImages addObject:obj];
                NSData *data = [(Consent*)obj valueForKey:@"imageFile"];
                NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                NSNumber *index = [NSNumber numberWithInteger:idx];
                [_cachedImages setObject:purgeableData forKey:index cost:data.length];
                
            }
            
        }];
        
        _dataArrayDidChange = @0;//= NO
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            if (refreshHUD) {
                [refreshHUD hide:YES];
                refreshHUD = nil;
            }
            [self showEmptyLabel];
            
            
        });
        
        
    }); //end of dispatch
    
}




- (void) loadAndCacheObjects {
    
    cloudRefresh(_allImages, dispatch_get_main_queue(), ^(NSMutableArray *allPhotos) {
        
        [self cacheImages:allPhotos];
        
        
    });
    
}

- (void)showHUD {
    
    
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    if (refreshHUD) {
        // Register for HUD callbacks so we can remove it from the window at the right time
        refreshHUD.delegate = self;
        [refreshHUD setAnimationType:MBProgressHUDAnimationFade];
        // Show the HUD while the provided method executes in a new thread
        [refreshHUD show:YES];
        
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        
        // Set custom view mode
        refreshHUD.mode = MBProgressHUDModeCustomView;
        
        [self.view addSubview:refreshHUD];
        [self showEmptyLabel];
    }
    
    
    
}


- (void) clearCollectionView {
    if (_allImages) {
        [_allImages removeAllObjects];
        _allImages = nil;
    }
    if (_cachedImages) {
        [_cachedImages removeAllObjects];
        _cachedImages = nil;
        
    }
    if (self.collectionView.visibleCells.count > 0) {
        [self.collectionView performBatchUpdates:^{
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
            [self.collectionView deleteSections:indexSet];
        } completion:^(BOOL finished) {
            if (finished)
                [self showEmptyLabel];
        }];
    }
    [self showEmptyLabel];
   
    _dataArrayDidChange = @0;//= NO
    
}

#pragma mark - logout activity delegate called on activityDidFinish

- (void) userDidLogout:(id) sender {
    
    [self clearCollectionView];
    [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:NO]];
    
}



#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_allImages) {
        return 1;
    } else
        return 0;
    
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSLog(@"all images count - %lu", (unsigned long)_allImages.count);
    return [_allImages count];
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
    NSPurgeableData *imageData = [_cachedImages objectForKey:index];
    NSLog(@"Cache index = %d  indexPath.Row = %d", index.integerValue, indexPath.row);
    
    if (!imageData) { //image is not in the cache
        
        id eachObject = [_allImages objectAtIndex:indexPath.row];
        
        if ([eachObject isKindOfClass:[PFObject class]]) {
            PFFile *theImage = [eachObject objectForKey:@"imageFile"];
            
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self cacheData:data atIndex:index];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                });
                
                
                
            }];

        } else if ([eachObject isKindOfClass:[Consent class]]) {
            
            NSData *data = [eachObject valueForKey:@"imageFile"];
            [self cacheData:data atIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageWithData:data];
                [cell setNeedsLayout];
            });
            
        }
        
        
        
    } else
        
        if ([imageData beginContentAccess]) {
            imageView.image = [UIImage imageWithData:imageData];
            [imageData endContentAccess];
            [imageData discardContentIfPossible];
            [cell setNeedsLayout];
        }
    
    return cell;
    
}

- (void) cacheData:(NSData *)data atIndex: (NSNumber*) index {
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0UL);
    dispatch_async(queue, ^{
        NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
        [_cachedImages setObject:purgeableData forKey:index cost:data.length];
        [purgeableData endContentAccess];
        [purgeableData discardContentIfPossible];
        
    });
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //prevent the image being selected if it is still loading in the background
    PFObject* obj = [_allImages objectAtIndex:indexPath.row];
    NSDate* objectCreatedTime = [obj valueForKey:@"createdAt"];
    if (objectCreatedTime == NULL) {
    
        return NO;
    }
    return YES;
    
    
}

#pragma mark - Segue support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showCloudPhoto"]) {
        
        // hand off the assets of this album to our singleton data source
        [PageViewControllerData sharedInstance].photoAssets = _allImages;
        
        // start viewing the image at the appropriate cell index
        MyPageViewController *pageViewController = [segue destinationViewController];
        
            
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        pageViewController.startingIndex = selectedCell.row;
        
    } else if ([segue.identifier isEqualToString:@"showPanel"]) {
        PMMenuViewController *controller = segue.destinationViewController;
        [controller setDelegate:self];
    }

}

#pragma mark - Unwind
- (IBAction)completeConsent:(UIStoryboardSegue *)segue
{
    //    NSLog(@"Consent completed");
}


- (IBAction)actionButton:(id)sender {
    
    if (!_delegateInstance) {
        _delegateInstance = [[PMActivityDelegate alloc] init];
    }
    
    _activityDelegate = _delegateInstance;
    
    if ([_activityDelegate respondsToSelector:@selector(showActivitySheet:)]) {
        [(PMActivityDelegate*)_activityDelegate setSenderController:self];
        [_activityDelegate showActivitySheet:sender];
    }
    
    
}

void cloudRefresh(NSMutableArray* allImages, dispatch_queue_t queue, void (^block)(NSMutableArray *allPhotos))
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // create a PFQuery
        PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
        PFUser *user = [PFUser currentUser];
        [query whereKey:@"user" equalTo:user];
        [query orderByAscending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                // Retrieve existing objectIDs
                NSMutableArray *oldCompareObjectIDArray = [NSMutableArray array];
                for (PFObject *currentObject in allImages) {
                    
                    [oldCompareObjectIDArray addObject:[currentObject objectId]];
                    
                }
                
                NSMutableArray *oldCompareObjectIDArray2 = [NSMutableArray arrayWithArray:oldCompareObjectIDArray];
                
                // If there are photos, we start extracting the data
                // Save a list of object IDs while extracting this data
                NSMutableArray *newObjectIDArray = [NSMutableArray array];
                if (objects.count > 0) {
                    for (PFObject *eachObject in objects) {
                        [newObjectIDArray addObject:[eachObject objectId]];
                    }
                }
                
                // Compare the old and new object IDs
                NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
                NSMutableArray *newCompareObjectIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
                if (oldCompareObjectIDArray.count > 0) {
                    // New objects
                    [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray];
                    // Remove old objects if you delete them using the web browser
                    [oldCompareObjectIDArray removeObjectsInArray:newCompareObjectIDArray2];
                    if (oldCompareObjectIDArray.count > 0) {
                        // Check the position in the objectIDArray and remove
                        NSMutableArray *listOfToRemove = [[NSMutableArray alloc] init];
                        for (NSString *objectID in oldCompareObjectIDArray){
                            int i = 0;
                            for (NSString *oldObjectID in oldCompareObjectIDArray2){
                                if ([objectID isEqualToString:oldObjectID]) {
                                    // Make list of all that you want to remove and remove at the end
                                    [listOfToRemove addObject:[NSNumber numberWithInt:i]];
                                }
                                i++;
                            }
                        }
                        
                        // Remove from the back
                        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
                        [listOfToRemove sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
                        
                        for (NSNumber *index in listOfToRemove){
                            [allImages removeObjectAtIndex:[index intValue]];
                        }
                    }
                }
                
                // Add new objects
                for (NSString *objectID in newCompareObjectIDArray){
                    for (PFObject *eachObject in objects){
                        if ([[eachObject objectId] isEqualToString:objectID]) {
                            NSMutableArray *selectedPhotoArray = [[NSMutableArray alloc] init];
                            [selectedPhotoArray addObject:eachObject];
                            
                            if (selectedPhotoArray.count > 0) {
                                [allImages addObjectsFromArray:selectedPhotoArray];
                            }
                        }
                    }
                }
                //return the array of images in the completion block
                dispatch_async(queue, ^{
                    block(allImages);
                    
                    
                });
            }
            
        }];
        
    });
    
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hudWasHidden
{
    // remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
    HUD = nil;
}

#pragma mark  - shareActivity portocol delegate methods
- (void) shareActivity:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (!_delegateInstance) {
            _delegateInstance = [[PMActivityDelegate alloc] init];
        }
        [_delegateInstance setSenderController:self];
        _activityDelegate = _delegateInstance;
        
        
        
        if ([_activityDelegate respondsToSelector:@selector(showActivitySheet:)]) {
            [_activityDelegate showActivitySheet:sender];
        }
    }];
    
}


- (void) upgradePhotoConsent:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        PMUpgradeViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"upgradeViewController"];
        
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [nvc setTitle:@"Upgrade nav bar"];
        
        [vc setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:nvc animated:YES completion:nil];
    
    }];
    
}


- (void) showConsentTypes {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"referenceTableViewController"];
        [self presentViewController:nvc animated:YES completion:nil];
        
    }];
}


- (void) showDisclaimer {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"];
        [self presentViewController:avc animated:YES completion:nil];
    }];
}

#pragma mark - Transitioning Delegate Methods
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.2f;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    TLTransitionAnimator *animator = [TLTransitionAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TLTransitionAnimator *animator = [TLTransitionAnimator new];
    return animator;
}




#pragma mark - AtrributedString method
-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkGrayColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:19.0], NSTextEffectAttributeName:NSTextEffectLetterpressStyle} range:range];
    
    return attrMutableString;
}



@end
