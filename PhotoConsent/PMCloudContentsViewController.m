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
#import "UIColor+More.h"




typedef void(^LoadCacheDidFinish)(BOOL);
typedef void(^LoadCacheProgress)(CGFloat);


@interface PMCloudContentsViewController () <shareActivityProtocol,PMWorkOfflineActivityProtocol,PMLogoutActivityProtocol, PMWStopOfflineActivityProtocol,NSCacheDelegate,PageViewControllerImageToDisplayProtocol,PMRefreshCacheProtocol>

@property (strong, nonatomic)  UILabel *emptyLabel;

@property (strong, nonatomic) PMActivityDelegate* delegateInstance;
@property (strong, nonatomic) PMCameraDelegate* cameraDelegateInstance;
@property (strong, nonatomic) PMLoginActivityDelegate* loginActivityDelegate;


- (void)loadCache:(NSCache*)cache objects:(NSArray*)allPhotos  key:(NSString*) imageKey progress:(LoadCacheProgress)progress completionHandler:(LoadCacheDidFinish)completion;


@end

@implementation PMCloudContentsViewController
{
    MBProgressHUD *HUD;
    MBRoundProgressView *refreshHUD;
}

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
    _allImages = [[NSMutableArray alloc] init];
    

    _dataArrayDidChange = @0;
    
    if ([PFUser currentUser]) {
        [self refreshAndCacheObjects];
        [self titleViewWithEnableSwitch:YES];
    } else
        [self titleViewWithEnableSwitch:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"DID RECEIVE MEMORY WARNING!");
    [_cachedLargeImages removeAllObjects];
    _cachedLargeImages = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self setCanDisplayBannerAds:!isPaid()];
    
    if (_shouldDim) {
        [self.view setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
    } else
        [self.view setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    if ([PFUser currentUser]) {
        if (!_allImages) {
            _allImages = [[NSMutableArray alloc] init];
            [self refreshAndCacheObjects];
            
            
        } else {
            if (_dataArrayDidChange.boolValue == YES) {
                
                //rebuild smallImage cache
                [_cachedSmallImages removeAllObjects];
                [self loadCache:_cachedSmallImages objects:_allImages key:@"smallImageFile" progress:nil completionHandler:^(BOOL finished) {
                     [self.collectionView reloadData];
                }];
                
                
                
               
                NSInteger delayInSeconds = 4;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //ENABLE ACTION BUTTON WHICH HAD BEEN DISABLED TO PREVENT REFRESHING WHILE THE CLOUD WAS BEING UPDATED
                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
                });
                
                _dataArrayDidChange = @0; //= NO
            }
            
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
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are logged in - no photos to display"]]];
            } else
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"No offline photos to display"]]];
            
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
    } else //allImages is nil
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
            
            [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are logged out"]]];
            [self.view addSubview:_emptyLabel];
        }
    
}

#pragma mark - create image cache for cloud or device images and reload

//delegate to PMWorkOfflineActivity
- (void) loadAndCacheDeviceImages:(id) sender {
    
    if (![PFUser currentUser]) {
        [self clearCollectionView];
    }
    
    _allImages = [NSMutableArray arrayWithArray:[[ConsentStore sharedDeviceConsents] allDeviceConsents]];
    
    [self loadSmallAndLargeCachesWithImages:[[ConsentStore sharedDeviceConsents] allDeviceConsents]];
    
}

- (void)loadCache:(NSCache*)cache objects:(NSArray*)allPhotos  key:(NSString*) imageKey  progress:(LoadCacheProgress)progress completionHandler:(LoadCacheDidFinish)completion {
    
    
    if (allPhotos.count == 0) {
        return;
    }
    CGFloat photoTotal = allPhotos.count;
    [cache setName:imageKey];
    
    cache.delegate = self;
    [cache setEvictsObjectsWithDiscardedContent:NO];
    
    __block NSUInteger cacheCount = 0; __block CGFloat value;
    [allPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx < cache.countLimit) {
            
            cacheCount ++;
            
            if ([obj isKindOfClass:[PFObject class]]) {
                
                NSNumber *index = [NSNumber numberWithInteger:idx];
                PFFile *imageData = [(PFObject*)obj objectForKey:imageKey];
                
                if (imageData.isDataAvailable) {
                    
                    [self cacheData:[imageData getData] forCache:cache atIndex:index];
                    
                } else
                    [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        [self cacheData:data forCache:cache atIndex:index];
                    }];
                    
                
                       
            } else if ([obj isKindOfClass:[Consent class]]) {
                
                NSData *data = [(Consent*)obj valueForKey:@"imageFile"];
                NSNumber *index = [NSNumber numberWithInteger:idx];
                [self cacheData:data forCache:cache atIndex:index];
                
            }
        }
        
        if (progress) {
            if (cacheCount % 1 == 0) {
                value = ((CGFloat)cacheCount / photoTotal);
                progress(value);
                
            }
        }
        
        
    }];
    if (completion) {
        if (cacheCount == allPhotos.count) {
            completion(YES);
        } else
            completion(NO);
    }
    
    
    
}


- (void) loadSmallAndLargeCachesWithImages:(NSArray*)allPhotos {
    
    
    if (allPhotos.count == 0) {
        [self showEmptyLabel];
        return;
    }
    if (allPhotos.count > 10) {
        [self showHUD];
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        
        if (!_cachedSmallImages) {
            _cachedSmallImages = [NSCache new];
            [_cachedSmallImages setTotalCostLimit:(5 * 1024 * 1024)];
            [_cachedSmallImages setCountLimit:[allPhotos count]];
        }
        
        [self loadCache:_cachedSmallImages objects:allPhotos key:@"smallImageFile" progress:^(CGFloat progress) {
            
             NSLog(@"Small cache progress = %f", progress);
            dispatch_async(dispatch_get_main_queue(), ^{
              HUD.progress = progress;
            });
            
        }  completionHandler:^(BOOL finished) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"SMALL image cache finished loading");
                    _dataArrayDidChange = @0;//= NO
                    [self.collectionView reloadData];
                    [self clearHud];
                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
                });
            } else {
                
                //did not enumerat all photos - not likely
                [self clearHud];
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
            }
            
        
        }];
        
        
    });
    
    dispatch_group_async(group, queue2, ^{
        
        if (!_cachedLargeImages) {
            _cachedLargeImages = [NSCache new];
            [_cachedLargeImages setTotalCostLimit:((int)(allPhotos.count) * 1024 * 1024)];
            [_cachedLargeImages setCountLimit:[allPhotos count]];
        }
        
        [self loadCache:_cachedLargeImages objects:allPhotos key:@"imageFile"  progress:^(CGFloat progress) {
       
            NSLog(@"Large cache progress = %f", progress);
                  
        }  completionHandler:^(BOOL finished) {
            if (finished) {
                NSLog(@"LARGE image cache finished loading");
                
                [self clearHud]; //JUST IN CASE
            }
        }];
    });
    
    
}

-(void)clearHud {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (HUD) {
            [HUD hide:YES];
            HUD = nil;
            refreshHUD = nil;
            [self.view setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
        }
        [self showEmptyLabel];
    });
   
    
}

- (void) refreshAndCacheObjects {
    
     cloudRefresh(_allImages, dispatch_get_main_queue(), ^(NSArray *allPhotos) {
         
         [self loadSmallAndLargeCachesWithImages:allPhotos];

    });
             
}

- (void)showHUD {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    if (HUD) {
        HUD.mode = MBProgressHUDModeDeterminate;
        
        HUD.delegate = self;
        [HUD setAnimationType:MBProgressHUDAnimationFade];
        [HUD setColor:[UIColor darkGrayColor]];
        [HUD setLabelText:@"Loading.."];
        [HUD setLabelColor:[UIColor brightOrange]];
        refreshHUD = [[MBRoundProgressView alloc] initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
        if (refreshHUD) {
            
            [HUD addSubview:refreshHUD];
            [self.view addSubview:HUD];
            [HUD show:YES];
            [self.view setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
            [self showEmptyLabel];
        }
    }
    
}


- (void) clearCollectionView {
    if (_allImages) {
        [_allImages removeAllObjects];
        _allImages = nil;
    }
    if (_cachedSmallImages) {
        [_cachedSmallImages removeAllObjects];
        _cachedSmallImages = nil;
        
    }
    if (_cachedLargeImages) {
        [_cachedLargeImages removeAllObjects];
        _cachedLargeImages = nil;
        
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [self imageAtIndex:index forCache:_cachedSmallImages];
        imageView.image = image;
        [cell setNeedsLayout];
    });
    
      
    return cell;
    
}

// provides image for collectionViewCell and also acts as delegate to PageviewControllerData
- (UIImage*)imageAtIndex:(NSNumber*) index forCache:(NSCache*)imageCache {
   
    __block  UIImage* image;
    
    if (!imageCache) {
        PFObject *obj = [_allImages objectAtIndex:index.integerValue];
        if ([obj isKindOfClass:[PFObject class]]) {
            NSString *key = @"imageFile";
            
            PFFile *imageData = [obj objectForKey:key];
            if (imageData.isDataAvailable) {
                 NSLog(@"IMAGE NOT IN CACHE BUT DATA ISAVAILABLE - RETURNING IMAGE FOR CELL AT INDEX = %d", index.integerValue);
                NSData *data = [imageData getData];
                [self cacheData:data forCache:imageCache atIndex:index];
                image = [UIImage imageWithData:data];
                
    //     NSPurgeableData* purgeableData = [self cacheData:data forCache:imageCache atIndex:index];
    //      image = [UIImage imageWithData:purgeableData];
                
                
                return [UIImage imageWithData:data];
            } else {
                
                NSLog(@"WARNING!!! USING getDataInBackground - IMAGE NOT IN CACHE - RETURNING IMAGE FOR CELL AT INDEX = %d", index.integerValue);
                [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    [self cacheData:data forCache:imageCache atIndex:index];
                    image = [UIImage imageWithData:data];
                }];
            }
        }
    }
    //cache exists
    NSPurgeableData *imageData = [imageCache objectForKey:index];
    
    if (!imageData) { //image is not in the cache
        
        id eachObject = [_allImages objectAtIndex:index.integerValue];
        
        if ([eachObject isKindOfClass:[PFObject class]]) {
            NSString *key = imageCache.name;
            
            PFFile *imageData = [eachObject objectForKey:key];
            if (imageData.isDataAvailable) {
                NSLog(@"IMAGE NOT IN CACHE - BUT DATA IS AVAIALBLE RETURNING IMAGE FOR CELL AT INDEX = %d", index.integerValue);
                NSData *data = [imageData getData];
                image = [UIImage imageWithData:data];
    //     NSPurgeableData* purgeableData = [self cacheData:data forCache:imageCache atIndex:index];
                
        //  image = [UIImage imageWithData:purgeableData];
        //  [purgeableData endContentAccess];
                
            } else {
                
                NSLog(@"WARNING!!! USING getDataInBackground - IMAGE NOT IN CACHE - RETURNING IMAGE FOR CELL AT INDEX = %d", index.integerValue);
                [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    [self cacheData:data forCache:imageCache atIndex:index];
                    image = [UIImage imageWithData:data];
                }];
                
        //   NSPurgeableData* purgeableData = [self cacheData:data forCache:imageCache atIndex:index];
                
        //  image = [UIImage imageWithData:purgeableData];
                
        //   [purgeableData endContentAccess];
            }
           
       
            
        } else if ([eachObject isKindOfClass:[Consent class]]) {
            
            NSData *data = [eachObject valueForKey:@"imageFile"];
            
            image = [UIImage imageWithData:data];
            
            
    //    NSPurgeableData* purgeableData = [self cacheData:data forCache:imageCache atIndex:index];
       
    //   image = [UIImage imageWithData:purgeableData];
    // [imageData endContentAccess];
            
        }
        
        
        
    } else
        //image is in cache
        if ([imageData beginContentAccess]) {
            NSLog(@"IMAGE IN CACHE - RETURNING IMAGE FOR CELL AT INDEX = %d", index.integerValue);
            image = [UIImage imageWithData:imageData];
           
        }


    return image;
}


- (NSPurgeableData*) cacheData:(NSData *)data forCache:(NSCache*)cache atIndex: (NSNumber*) index {
    
    if (!data) {
        return nil;
    }
    __block NSPurgeableData *purgeableData;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0UL);
    dispatch_async(queue, ^{
        purgeableData = [NSPurgeableData dataWithData:data];
        [cache setObject:purgeableData forKey:index cost:data.length];
         NSLog(@"ADDING CACHED IMAGE TO CACHE %@ AT INDEX %lu",[cache name], (unsigned long)index.integerValue);
  //      [purgeableData beginContentAccess];
        
    });
    return purgeableData;
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
        
        [[PageViewControllerData sharedInstance] setDelegate:self];
        [[PageViewControllerData sharedInstance] setPhotoAssets:_allImages];
        
//      [[PageViewControllerData sharedInstance] setLargeCachedImages:_cachedLargeImages];
        
        // start viewing the image at the appropriate cell index
        MyPageViewController *pageViewController = [segue destinationViewController];
        
//      [pageViewController setRefreshCacheDelegate:self];
            
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
        query.limit = 400;
        
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
                
                // Compare the old and newLY refreshed object IDs
                NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
                NSMutableArray *newCompareObjectIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
                if (oldCompareObjectIDArray.count > 0) {
                    // New objects
                    [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray];
                    // Remove old objects that have been deleted using the web browser
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
                    NSLog(@"Count allImages after refresh = %lu", (unsigned long)allImages.count);
                    
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

#pragma mark  - shareActivity protocol delegate methods
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
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController: [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"]];
            
        [self presentViewController:nvc animated:YES completion:nil];
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

#pragma mark - NSCache delegate protocol
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    
    NSLog(@"Will evict this object from cache %@ with length %@", cache.name, [obj valueForKey:@"length"]);
}


-(void)tintColorDidChange {
    if (self.view.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
        [self.view setAlpha:0.40];
    } else
        [self.view setAlpha:1.0];
}


@end
