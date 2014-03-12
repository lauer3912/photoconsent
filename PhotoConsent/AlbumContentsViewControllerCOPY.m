//
//  AlbumContentsViewController.h
//  Photoconsent
//
//  Created by Alex Rafferty on 18/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//


#import "AlbumContentsViewController.h"
#import "MyPageViewController.h"
#import "PageViewControllerData.h"
#import "PMConsentDetailViewController.h"
#import "PMDisclaimerViewController.h"
#import "ConsentStore.h"
#import "Consent.h"
#import "PMTextConstants.h"
#import "TLTransitionAnimator.h"
#import "PMActivityDelegate.h"
#import "PMFunctions.h"


@interface AlbumContentsViewController () 
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic)  UILabel *emptyLabel;
@property (strong, nonatomic) PMActivityDelegate* delegateInstance;

@end


@implementation AlbumContentsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	_assetsArrayDidChange = YES; //want to run loadAssets when loading
    self.title = @"Album";
    [self checkDisclaimer];
}

-(void) loadAssets {
    
    
    if (!_assetsLibrary) {
        _assetsLibrary = [ALAssetsLibrary new];
    }
    
    if (!_assets)
        _assets = [[NSMutableArray alloc] init];
    else if (_assets.count > 0)
        [_assets removeAllObjects];
    
     NSLog(@"START LOAD ASSETS:Device consent count = %d", [[ConsentStore sharedDeviceConsents] allDeviceConsents].count );
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
        if ([name isEqualToString:@"PhotoConsent"]) {
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result)
                    [_assets addObject:result];
            }];
            [self.collectionView reloadData];
            
            if ([_assets count] > 0) {
                if (_emptyLabel)
                    [_emptyLabel removeFromSuperview];
            } else {  //no photos in album
                if (!_emptyLabel)
                    _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
                
                _emptyLabel.backgroundColor = [UIColor clearColor];
                [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"The %@ album is empty", name]]];
                [_emptyLabel setNumberOfLines:2];
                [self.view addSubview:_emptyLabel];
            }
            
           
            
            if ([_assets count] < [[ConsentStore sharedDeviceConsents] allDeviceConsents].count > 0) {
                
                
                
                // delete orphan deviceConsents
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [[[ConsentStore sharedDeviceConsents] allDeviceConsents] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        __block BOOL found = NO;
                        NSURL *consentURL = [(Consent*)obj assetURL];
                        [_assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            
                            NSURL *assetURL = [(ALAsset*)obj valueForProperty:ALAssetPropertyAssetURL];
                            if ([consentURL isEqual: assetURL] ) {
                                found = YES;
                                *stop = YES;
                            }
                            
                        }]; // end of ALAssets enumeration
                        if (!found) {
                            [[ConsentStore sharedDeviceConsents] deleteDeviceConsent:obj];
                            
                            NSLog(@"deviceConsent removed from store %@", [(Consent*)obj referenceID]);
                            
                        }
                        found = NO;
                        
                    }]; // end of consents enumeration
                    [[ConsentStore sharedDeviceConsents] saveChanges];
                    
                    
                }); //end of dispatch
                
            }
            _assetsArrayDidChange = NO;
            *stop = YES;
            
        }
        
        
        
    } failureBlock:^(NSError *error) {
        NSLog(@"access denied to PhotoConsent album \n  %@", [[error userInfo] valueForKey:NSLocalizedDescriptionKey]);
    }];
    NSLog(@"END:Device consent count = %d", [[ConsentStore sharedDeviceConsents] allDeviceConsents].count );
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    if (_assetsArrayDidChange) {
        [self loadAssets];
    }
    
   
    
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [_assets count];
}



static const int kImageViewTag = 1; // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0UL);
    dispatch_async(queue, ^{
        ALAsset *asset = self.assets[indexPath.row];
        
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        
        UIImage *defaultImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]                                   scale: [assetRepresentation scale] orientation:(UIImageOrientation)ALAssetOrientationUp];
    /*
        CGImageRef imageRef = [asset thumbnail];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        UIImage *defaultImage =  resizeImage(image, CGSizeMake(60.0, 60.0));
     */
        dispatch_sync(dispatch_get_main_queue(), ^{
            // load the asset for this cell
         
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
            imageView.image = defaultImage;
            [cell setNeedsLayout];
        });
    });

    return cell;
}


#pragma mark - Segue support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showPhoto"]) {
        
        // hand off the assets of this album to our singleton data source
        [PageViewControllerData sharedInstance].photoAssets = _assets;
        
        // start viewing the image at the appropriate cell index
        MyPageViewController *pageViewController = [segue destinationViewController];
       
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        pageViewController.startingIndex = selectedCell.row;
    }
    else if ([segue.identifier isEqualToString:@"goToConsentScreens"]) {
        PMConsentDetailViewController *controller = segue.destinationViewController;
        controller.userPhoto = sender;
    }

}

#pragma mark - Unwind
- (IBAction)completeConsent:(UIStoryboardSegue *)segue
{
    //    NSLog(@"Consent completed");
}

#pragma mark - action Button pressed
- (IBAction)actionButton:(id)sender {
    
    if (!_delegateInstance) {
        _delegateInstance = [[PMActivityDelegate alloc] init];
    }
    
    _activityDelegate = _delegateInstance;
    
    if ([_activityDelegate respondsToSelector:@selector(showActivitySheet:)]) {
        [_activityDelegate showActivitySheet:self];
    }
    
    
}
#pragma mark -  IBAction buttons pressed
- (IBAction)albumRefresh:(id)sender {
    [self loadAssets];
}

-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor lightGrayColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0]} range:range];
    
    return attrMutableString;
}


#pragma mark - UIViewControllerTransitioningDelegate
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    TLTransitionAnimator *animator = [TLTransitionAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TLTransitionAnimator *animator = [TLTransitionAnimator new];
    return animator;
}

- (void)checkDisclaimer {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *disclaimerAcknowledged = [userDefaults objectForKey:@"disclaimerAcknowledged"];
    
    if (![disclaimerAcknowledged boolValue] == YES) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"disclaimerViewController"];
       // avc.transitioningDelegate = self;
        [avc setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:avc animated:YES completion:^{
            
        }];
    }
}


@end

