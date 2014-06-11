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
#import <MobileCoreServices/UTCoreTypes.h>
#import "MyPageViewController.h"
#import "PMLoginViewController.h"
#import "PMSignUpViewController.h"
#import "PageViewControllerData.h"
#import "PMCompleteViewController.h"
#import "PMConsentDetailViewController.h"
#import "PMActivityDelegate.h"
#import "PMMenuViewController.h"
#import "TLTransitionAnimator.h"
#import "PMLoginActivityDelegate.h"
#import "Consent.h"
#import "ConsentStore.h"
#import "PMWorkOfflineActivity.h"
#import "PMLogoutActivity.h"
#import "PMLoginActivity.h"
#import "PMUpgradeViewController.h"
#import "PMFunctions.h"
#import "PMUsePhotoViewController.h"
#import "PMDisclaimerViewController.h"
#import "PMAppDelegate.h"


typedef void(^LoadCacheDidFinish)(BOOL);
typedef void(^LoadCacheProgress)(CGFloat);

typedef void(^SmallCacheCompletion)(BOOL);


static const NSInteger showHudLimit = 0;
static const NSInteger savingMessageTag = 46;
static const NSInteger kImageViewTag  = 1;
static const NSInteger kCameraBtnTag  = 27;

@interface PMCloudContentsViewController () <shareActivityProtocol,PMWorkOfflineActivityProtocol,PMLogoutActivityProtocol, PMWStopOfflineActivityProtocol,NSCacheDelegate,PageViewControllerImageToDisplayProtocol,ConsentDelegate>

@property (strong, nonatomic)  UILabel *emptyLabel;
@property (strong, nonatomic)  PMActivityDelegate* delegateInstance;
@property (strong, nonatomic)  PMLoginActivityDelegate* loginActivityDelegate;
@property (strong, nonatomic)  PFQuery *query;

//used by camera delegate
@property (strong, nonatomic) NSString *referenceID;

@property (assign,nonatomic) BOOL isSaving;

//PFObjects being saved
@property (strong, nonatomic) NSMutableArray *photosBeingSaved;

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
    
    _photosBeingSaved = [NSMutableArray new];
    
    // register for NSNotification on subscription purchase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canDisplayAds) name:@"AppStorePurchaseNotification" object:nil];
    
    
    if ([PFUser currentUser]) {
        
       [self.navigationItem setTitleView:[self titleViewWithEnableSwitch:YES]];
    } else
       [self.navigationItem setTitleView:[self titleViewWithEnableSwitch:NO]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"DID RECEIVE MEMORY WARNING!");
    [_cachedLargeImages removeAllObjects];
    _cachedLargeImages = nil;
    
}

- (void) canDisplayAds {
     [self setCanDisplayBannerAds:!isPaid()];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
     
    [self canDisplayAds];
    
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
               [self loadCacheWithSmallImages:_allImages completionHandler:^(BOOL completion)  {
                   [self.collectionView reloadData];
                   _dataArrayDidChange = @0; //= NO
               }];
                
                
            }
            
        }
         
        
    } else {
        //not logged in
        if (_allImages.count == 0) {
            [self userDidLogout:nil];
        }
        if (_dataArrayDidChange.boolValue == YES) {
            [self loadAndCacheDeviceImages:nil];
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
        cameraBtn.tag = kCameraBtnTag;
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
        
            [self startCamera];
       
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
        [self clearHud];
        return;
    }
    
    
    if (_allImages) {
        
        if (_allImages.count == 0) {
            [self clearCollectionView];
            if (!_emptyLabel) {
                _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
                _emptyLabel.backgroundColor = [UIColor clearColor];
                [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
            }
            
            
            if ([PFUser currentUser]) {
                [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:YES]];
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"No photos available"]]];
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
    } else { //allImages is nil
        
        if (_emptyLabel) {
            [_emptyLabel removeFromSuperview];
        } else {
            
            _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            _emptyLabel.backgroundColor = self.collectionView.backgroundColor;
            [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
        }
    
       
        if ([PFUser currentUser]) {
            [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:YES]];
            [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"No photos available"]]];
            [self.view addSubview:_emptyLabel];
        } else {
            [self.navigationItem setTitleView: [self titleViewWithEnableSwitch:NO]];
            [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are logged out"]]];
            [self.view addSubview:_emptyLabel];
        }
    }
}

#pragma mark - create image cache for cloud or device images and reload

//delegate to PMWorkOfflineActivity
- (void) loadAndCacheDeviceImages:(id) sender {
    
    if (![PFUser currentUser]) {
        [self clearCollectionView];
    }
    
    _allImages = [NSMutableArray arrayWithArray:[[ConsentStore sharedDeviceConsents] allDeviceConsents]];
    
    [self loadCacheWithSmallImages:_allImages completionHandler:^(BOOL completion) {
        [self.collectionView reloadData];
    }];
    
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
                
                NSData *data = [(Consent*)obj valueForKey:@"smallImageFile"];
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
        completion(YES);
       
    }
    
    
    
}
- (NSCache*) createCacheWithCountLimit:(NSUInteger)limit costLimit:(NSUInteger)costLimit {
     NSCache* cache = [NSCache new];
    [cache setTotalCostLimit:costLimit];
    [cache setCountLimit:limit];
    return cache;
}


- (void) loadCacheWithSmallImages:(NSArray*)allPhotos completionHandler:(SmallCacheCompletion)completion {
    
    
    NSLog(@"allImages count = %d", allPhotos.count);
    
    if (allPhotos.count == 0) {
        [self showEmptyLabel];
        return;
    }
    
    
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        
        if (!_cachedSmallImages)
            _cachedSmallImages = [self createCacheWithCountLimit:300 costLimit:(5 * 1024 * 1024)];
        
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
                   // [self.collectionView reloadData];
                    [self clearHud];
                    
                    if (completion) {
                        completion(YES);
                        
                    }
                    
                });
            } else {
                
                if (completion) {
                    completion(NO);
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self clearHud];
                    
                });
                
            }
            
            
        }];
        
        
    });
}

/*
- (void) loadSmallAndLargeCachesWithImages:(NSArray*)allPhotos {
    
  //WARNING - the large image cache will require substantial memory allocation to load all images into the cach. This caused problems with over 50 images - so not using the large cache for now 9/5/14
    NSLog(@"allImages count = %d", allPhotos.count);
    
    if (allPhotos.count == 0) {
        [self showEmptyLabel];
        return;
    }
    if (allPhotos.count > showHudLimit) {
        [self showHUD];
    }
    
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        
        if (!_cachedSmallImages)
            _cachedSmallImages = [self createCacheWithCountLimit:300 costLimit:(5 * 1024 * 1024)];
            
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
                    
                });
            } else {
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self clearHud];
                    
                });
                    
            }
            
        
        }];
        
        
    });
    
    dispatch_group_async(group, queue2, ^{
        
        if (!_cachedLargeImages) 
                 _cachedLargeImages = [self createCacheWithCountLimit:300 costLimit:(50 * 1024 * 1024)];
     
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
*/

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
    
   
    //Reachability
    PMAppDelegate *appDelegate = (PMAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (![appDelegate isParseReachable]) {
        
        NSError *error = createErrorWithMessage(@"The Cloud server is not reachable", @321);
        dispatch_async(dispatch_get_main_queue(), ^{
            showConnectionError(error);
            [self showEmptyLabel];
        });
        
        return;
    }

    
    if (_allImages.count >= showHudLimit) {
        [self showHUD];
    }
    
    if (_emptyLabel) {
        [_emptyLabel removeFromSuperview];
    }
    
    if (!_allImages) {
        _allImages = [NSMutableArray new];
    }
    
    id<UIAlertViewDelegate> alertviewDelegate = self;
    _query = refreshQuery();
     cloudRefresh(_query,_allImages,alertviewDelegate ,^(NSArray *allPhotos, NSError *queryError) {
         
         if (!queryError) {
             [self loadCacheWithSmallImages:allPhotos completionHandler:^(BOOL completion) {
                 [self.collectionView reloadData];
             }];
         } else
             [self clearHud];
         
         
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
        [HUD setLabelColor:[UIColor orangeColor]];
        refreshHUD = [[MBRoundProgressView alloc] initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
        if (refreshHUD) {
            
            [HUD addSubview:refreshHUD];
            [self.view addSubview:HUD];
            
            [HUD show:YES];
            [self.view setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
     
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
    
    /*
     //not using cachedLargeImages
    if (_cachedLargeImages) {
        [_cachedLargeImages removeAllObjects];
        _cachedLargeImages = nil;
        
    }
     */
     
    if (self.collectionView.visibleCells.count > 0) {
        [self.collectionView performBatchUpdates:^{
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
            [self.collectionView deleteSections:indexSet];
        } completion:^(BOOL finished) {
            if (finished)
                [self showEmptyLabel];
        }];
    } else
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
    NSLog(@"all images count for section %d is %lu", section, (unsigned long)_allImages.count);
    return [_allImages count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    
    NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [self imageAtIndex:index forCache:_cachedSmallImages];
        imageView.image = image;
        if (_isSaving) {
            if (indexPath.row == _allImages.count - 1) {
                [self addSavingMessageToImageView:imageView];
                
                NSLog(@"Adding saving message to cell at indexPath row %d", indexPath.row);
            }
            
            
        }
        [cell setNeedsLayout];
    });
    
      
    return cell;
    
}

// provides image for collectionViewCell and also acts as delegate to PageviewControllerData
- (UIImage*)imageAtIndex:(NSNumber*) index forCache:(NSCache*)imageCache {
   
    UIImage* image;
    //note the cache name is the same as the field name in PFObjet and Consent classes
    NSString *key = imageCache.name;
    //cache exists
    NSPurgeableData *cacheData = [imageCache objectForKey:index];
    
    if (!cacheData) { //image is not in the cache
        
        id eachObject = [_allImages objectAtIndex:index.integerValue];
        
        if ([eachObject isKindOfClass:[PFObject class]]) {
            
            PFFile *file = [eachObject valueForKey:key];
            
            
            NSData *data = [file getData];
            if (data) {
                NSPurgeableData *purgeableData = [self cacheData:data forCache:imageCache atIndex:index];
                image = [UIImage imageWithData:data];
                [purgeableData endContentAccess];
                
                NSLog(@"IMAGE NOT IN CACHE - ADDING IMAGE TO CACHE FOR CELL AT INDEX = %ld", (long)index.integerValue);

            } else
                //placeholder
                image = [UIImage imageNamed:@"iconwatermark"];
            
        } else if ([eachObject isKindOfClass:[Consent class]]) {
            NSLog(@"CONSENT IMAGE NOT IN CACHE - FOR CELL AT INDEX = %ld", (long)index.integerValue);

            NSData *data = [eachObject valueForKey:key];
            NSPurgeableData* purgeableData = [self cacheData:data forCache:imageCache atIndex:index];
            image = [UIImage imageWithData:data];
            [purgeableData endContentAccess];
           
        }
        return image;
        
    } else {
        //image is in cache
        [cacheData beginContentAccess];
        NSLog(@"IMAGE IN CACHE - RETURNING IMAGE FOR CELL AT INDEX = %ld", (long)index.integerValue);
        image = [UIImage imageWithData:cacheData];
        [cacheData endContentAccess];
        return image;
    
    }

    
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
    
         NSLog(@"ADDING IMAGE TO CACHE %@ AT INDEX %lu",[cache name], (unsigned long)index.integerValue);
        
    });
    return purgeableData;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([PFUser currentUser]) {
        //prevent the image being selected if it is still loading in the background
        PFObject* obj = [_allImages objectAtIndex:indexPath.row];
        NSDate* objectCreatedTime = [obj valueForKey:@"createdAt"];
        if (objectCreatedTime == NULL) {
            
            return NO;
        }
    }
    
    return YES;
    
    
}


#pragma mark - Segue support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showCloudPhoto"]) {
        
        [[PageViewControllerData sharedInstance] setDelegate:self];
        [[PageViewControllerData sharedInstance] setPhotoAssets:_allImages];
        
        // start viewing the image at the appropriate cell index
        MyPageViewController *pageViewController = [segue destinationViewController];
        
            
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        pageViewController.startingIndex = selectedCell.row;
        [pageViewController setIsSaving:_isSaving];
        [pageViewController setIsSavingCount:_photosBeingSaved.count];
        
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
    
    
    if ([_delegateInstance respondsToSelector:@selector(showActivitySheet:)]) {
        [_delegateInstance setSenderController:self];
        [_delegateInstance setConsentDelegate:self];
        [_delegateInstance setAlertviewDelegate:self];
        [_delegateInstance showActivitySheet:sender];
        [_delegateInstance setIsSaving:_isSaving];
    }
    
    
}

/*

PFQuery* refreshQuery() {
    // create a PFQuery
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
    [query orderByAscending:@"createdAt"];
    query.limit = 400;
    return query;
    
}

void cloudRefresh(PFQuery* query,NSMutableArray* allImages, dispatch_queue_t queue, void (^block)(NSMutableArray *allPhotos, NSError *queryError))
{
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        //Reachability
        PMAppDelegate *appDelegate = (PMAppDelegate*)[[UIApplication sharedApplication] delegate];
      
        if (![appDelegate isParseReachable]) {
            
            //create error object
            NSNumber *errorCode = @321;
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"The Cloud server is not reachable",@"code":errorCode};
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:321 userInfo:userInfo];
            //main queue
            dispatch_async(queue, ^{
                block(allImages, error);
                NSLog(@"Count allImages after refresh = %lu", (unsigned long)allImages.count);
                showConnectionError(error);
                
            });
            
            return;
        }
        
        
        
        
        

          //connection is reachable so start processing the query
         //start the timer to check every 5 seconds if save still processing
        
        dispatch_source_t timeoutTimer = startConnectionTimer(^{
            
            //no connection give user the option to cancel
            NSString *errorLocalizedString  = @"Connection may be lost or intermittent. Do you want to continue?";
            UIAlertView *showTimeOutOption = [[UIAlertView alloc] initWithTitle:@"The Cloud server is not reachable" message: errorLocalizedString delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
            showTimeOutOption.tag = 2;
            [showTimeOutOption show];
            
            
        });

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
            
                 NSLog(@"Count OBJECTS returned by query = %lu", (unsigned long)objects.count);
                
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
                
            } else {
                //dodgy connection
                showConnectionError(error);
               
            }
            //return the array of images in the completion block
            dispatch_async(queue, ^{
                block(allImages, error);
                
            });
            
            
        }];
        
    });
    
}
*/

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
                
        if ([_delegateInstance respondsToSelector:@selector(showActivitySheet:)]) {
            [_delegateInstance setSenderController:self];
            [_delegateInstance showActivitySheet:sender];
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
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"];
        if ([vc isKindOfClass:[PMDisclaimerViewController class]]) {
            PMDisclaimerViewController *avc = (PMDisclaimerViewController*)vc;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
            UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:avc action:@selector(cancel:)];
            
            [avc.navigationItem setRightBarButtonItem:cancelBtn];
                
            [self presentViewController:nc animated:YES completion:nil];
        }
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
    
    UIColor *foregroundColour = [UIColor lightGrayColor];
    
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
        [self.view setAlpha:0.70];
    } else
        [self.view setAlpha:1.0];
}


#pragma mark - Camera delegate moved here
- (void) startCamera {
    
    _cameraController = [UIImagePickerController new];
    
    // Set source to camera
    _cameraController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    _cameraController.delegate = self;
    _cameraController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    [self addOverlayViewForCameraController:_cameraController];
    
   [self presentViewController:_cameraController animated:YES completion:nil];
        
    
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    // Access the uncropped image from info dictionary
    _image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    //use overlayview to confirm use of photo
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    PMUsePhotoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"referenceIDViewController"];
    
    [(UIImageView*)vc.view setImage:_image];
    
    
    //remove buttons
    [[picker.view viewWithTag:27] removeFromSuperview];
    [[picker.view viewWithTag:46] removeFromSuperview];
    
    [vc setAlertViewDelegate:self];
    
    vc.view.tag = 100;
    
    CGRect frame = vc.view.frame;
    
    frame.size.height = 70.0;
    frame.origin.y = vc.view.frame.size.height - frame.size.height;
    
    
    CGRect leftBtnFrame = CGRectMake(30.0, 20.0, 80.0, 40.0);
    CGRect rightBtnFrame = CGRectMake(200.0, 20.0, 100.0, 40.0);
    UIView  *overlayView = [self cameraOverlayView:frame];
    
    [overlayView addSubview:[self retakeBtn:[PMCloudContentsViewController standardOverlayBtn:leftBtnFrame]]];
    [overlayView addSubview:[self usePhotoBtn:[PMCloudContentsViewController standardOverlayBtn:rightBtnFrame]]];
    
    [vc.view addSubview:overlayView];
    
    
    [_cameraController pushViewController:vc animated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
   
    switch (alertView.tag) {
        
        case 1: case 2://alertview containing text for reference ID
            if (buttonIndex != 0) {
                _referenceID = [[alertView textFieldAtIndex:0] text];
                
                cloudPhoto(_image, _referenceID, dispatch_get_main_queue(), ^(id userPhoto) {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                    
                    PMConsentDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"consentDetail"];
                    
                    [vc setUserPhoto:userPhoto];
                    [vc setConsentDelegate:self];
                    
                    [_cameraController setNavigationBarHidden:NO animated:YES];
                    
                    [_cameraController pushViewController:vc animated:YES];
                    
                    
                });
                
                
            } else {
                if (alertView.tag == 2) {
                    //coming back from consent details
                    //cancel as it crashes if poptoRootViewController
                    [self didCancelConsent];
                } else
                    [self retake];
            }
            break;
            
        case 3://timeout timer
            
            if (buttonIndex == 0) {
                PMAppDelegate *appDelegate = (PMAppDelegate*)[[UIApplication sharedApplication] delegate];
                dispatch_source_cancel(appDelegate.timeoutTimer);
                [_query cancel];
                [self clearHud];
            } else {
                PMAppDelegate *appDelegate = (PMAppDelegate*)[[UIApplication sharedApplication] delegate];
                dispatch_resume(appDelegate.timeoutTimer);
                
            }
            break;
        default:
            break;
    }
    
    
    
}


#pragma mark - consentDelegate methods
- (void) didCompleteConsentForPhoto:(PFObject*)photo {
    //THIS METHOD GETS CALLED WHEN THE PHOTO SAVE IS STARTED
 
    _isSaving = YES;
    
   
    /*
    //Disable the action and camera buttons to prevent refresh an/or new photo being taken
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    if ([PFUser currentUser]) {
       UIView *cameraBtn = [self.navigationItem.titleView viewWithTag:kCameraBtnTag];
        if ([cameraBtn isKindOfClass:[UIButton class]]) {
            [(UIButton*)cameraBtn setEnabled:NO];
        }
    }
    */
    
    //add the new photo and rebuild smallImage cache
    
    if (!_allImages) {
        //need to test here as on first photo entered allImages and cache will be nil
        _allImages = [NSMutableArray new];
        if (_emptyLabel) {
            [_emptyLabel removeFromSuperview];
        }
    }
    
    if (!_cachedSmallImages)
        _cachedSmallImages = [self createCacheWithCountLimit:300 costLimit:(5 * 1024 * 1024)];
    
    [_allImages addObject:photo];
       
    NSIndexPath *indexPath = [self indexPathForLastPhoto];
    NSNumber *nextIndex = @(indexPath.row);
    
    [_photosBeingSaved addObject:photo];
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
   
    
    dispatch_group_async(group, queue1, ^{
        PFFile *imageData = [(PFObject*)photo objectForKey:@"smallImageFile"];
        
        if (imageData.isDataAvailable) {
            
            
            [self cacheData:[imageData getData] forCache:_cachedSmallImages atIndex:nextIndex];
            
        }
        
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    
    [self.collectionView performBatchUpdates:^{
        //make sure the collectionView has at least one section - crahes if not section which can happen as found in testing
        if ([self.collectionView numberOfSections] == 0) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            [self.collectionView insertSections:indexSet];
        }
       
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
        
    } completion:^(BOOL finished) {
        if (finished) {
             [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
       
    }];
        
    //wait a few seconds before showing Saving message as with good connection might save might finish quickly
    NSInteger delayInSeconds = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (_isSaving) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            UIView *savingMessage = [cell viewWithTag:savingMessageTag];
            [savingMessage setHidden:NO];
        }
        
    });

    
      [self didCancelConsent];
    
}

- (void) didCancelConsent {
    
    [_cameraController dismissViewControllerAnimated:YES completion:^{
        
        if (_activity) {
            [_activity activityDidFinish:YES];
            _activity = nil;
        }
        
    }];
}

- (void) didFinishSavingPhoto:(PFObject*)photo saved:(BOOL)saved {
    
    //GETS CALLED WHEN THE PHOTO HAS BEEN SAVED
    
    //remove the objet from the array of photos being saved and set the isSaving flag to NO if the array has 0 objects
    [_photosBeingSaved removeObject:photo];
    _isSaving = _photosBeingSaved.count > 0;
    
    NSInteger delayInSeconds = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        [self removeSavingMessageAtIndexPath:[self indexPathForPhoto:photo]];
        if (!saved) {
            //either the save timed out or there was an error - need to delete the photo from the collectionview, allImages and the cachedSmallImages
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The photo was not saved." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles: nil];
            [alert show];
            [self removePhoto:photo];
        }
        
        
    });
    
    
}

- (void)addSavingMessageToImageView:(UIImageView*)imageView {

    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"Saving.."];
    [label setTextColor:[UIColor lightTextColor]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setHidden:YES];
    [label setTag:savingMessageTag];
    [imageView addSubview:label];
    
}


- (void) removeSavingMessageAtIndexPath:(NSIndexPath*)indexPath {
    
    //remove the "saving" message from cell
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *savingMessage = [cell viewWithTag:savingMessageTag];
    if (savingMessage) {
        [savingMessage removeFromSuperview];
        
    }
    
}

- (void)removePhoto:(PFObject*)photo {
    
    //either the save timed out or there was an error - need to delete the photo from the collectionview, allImages and the cachedSmallImages
    NSIndexPath *indexPath = [self indexPathForPhoto:photo];
    [_allImages removeObject:photo];
    [_cachedSmallImages removeObjectForKey:@(indexPath.row)];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
     
    NSLog(@"The Save may have failed so removing photo from cache, allImages and collectionview");
}

#pragma mark - indexPath helpers
-(NSIndexPath*)indexPathForLastPhoto {
    NSUInteger row = _allImages.count - 1;
    NSUInteger section = 0;
    NSUInteger indexes[] = {section,row};
    return [[NSIndexPath alloc] initWithIndexes:indexes length:2];
    
}

-(NSIndexPath*)indexPathForPhoto:(PFObject*)photo {
    NSUInteger row = [_allImages indexOfObject:photo];
    NSUInteger section = 0;
    NSUInteger indexes[] = {section,row};
    return [[NSIndexPath alloc] initWithIndexes:indexes length:2];
    
}


#pragma mark - overlayView for camera
//used by camera but but not with cameraRollActivity as source type must be camera
- (void) addOverlayViewForCameraController:(UIImagePickerController*)cameraController {
    
    
    CGRect frame = _cameraController.view.frame;
    
    frame.size.height = 70.0;
    frame.origin.y = _cameraController.view.frame.size.height - frame.size.height;
    
    cameraController.showsCameraControls = NO;
    UIView  *overlayView = [self cameraOverlayView:frame];
    
    CGRect leftBtnFrame = CGRectMake(30.0, 20.0, 80.0, 40.0);
    CGRect rightBtnFrame = CGRectMake(200.0, 20.0, 100.0, 40.0);
    
    
    [overlayView addSubview:[self cancelBtn:[PMCloudContentsViewController standardOverlayBtn:leftBtnFrame]]];
    [overlayView addSubview:[self takePictureBtn:[PMCloudContentsViewController standardOverlayBtn:rightBtnFrame]]];
    [overlayView setTag:27];
    [_cameraController.view addSubview:overlayView];
}


- (UIView*)cameraOverlayView:(CGRect) frame {
    
    
    UIView *overlayView = [[UIView alloc] initWithFrame:frame];
    
    [overlayView setBackgroundColor:[UIColor whiteColor]];
    [overlayView setAlpha:0.85];
    
    return overlayView;
}

+ (UIButton*)standardOverlayBtn:(CGRect) frame {
    UIButton *stdOverlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stdOverlayBtn setFrame:frame];
    [stdOverlayBtn setBackgroundColor:[UIColor clearColor]];
    [stdOverlayBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [stdOverlayBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    return stdOverlayBtn;
}

- (UIButton*)takePictureBtn:(UIButton*)takePictureBtn {
    
    [takePictureBtn addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [takePictureBtn setTitle:@"Capture" forState:UIControlStateNormal];
    return takePictureBtn;
}
- (UIButton*)cancelBtn:(UIButton*)cancelBtn {

    [cancelBtn addTarget:self action:@selector(didCancelConsent) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    return cancelBtn;
    
}


- (UIButton*)usePhotoBtn:(UIButton*)usePhotoBtn {
    
    [usePhotoBtn addTarget:self action:@selector(usePhoto) forControlEvents:UIControlEventTouchUpInside];
    [usePhotoBtn setTitle:@"Use Photo" forState:UIControlStateNormal];
    return usePhotoBtn;
}



- (UIButton*)retakeBtn:(UIButton*)retakeBtn {
    
    [retakeBtn addTarget:self action:@selector(retake) forControlEvents:UIControlEventTouchUpInside];
    [retakeBtn setTitle:@"Retake" forState:UIControlStateNormal];
    return retakeBtn;
}



- (void) capture {
    
    [_cameraController takePicture];
}

- (void) usePhoto {
    
    //add a reference ID
    UIAlertView *referenceID = [[UIAlertView alloc] initWithTitle:@"Reference Identifier" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Done",nil];
    [referenceID setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [referenceID textFieldAtIndex:0];
    [textField setTextColor:[UIColor blueColor]];
    [textField setPlaceholder:@"Add a photo identifier"];
    referenceID.tag = 1;
    [referenceID show];
   
}

- (void) retake {
    [self addOverlayViewForCameraController:_cameraController];
    [_cameraController popToRootViewControllerAnimated:NO];
}

@end
