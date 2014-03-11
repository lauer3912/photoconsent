//
//  PMCloudContentsViewController.m
//  Photoconsent
//
//  Created by Alex Rafferty on 18/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMCloudContentsViewController.h"
#import "MyPageViewController.h"
#import "PMLoginViewController.h"
#import "PMSignUpViewController.h"
#import "PageViewControllerData.h"
#import "PMCompleteViewController.h"
#import "PMConsentDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TLTransitionAnimator.h"
#import "PMActivityDelegate.h"

@interface PMCloudContentsViewController ()
@property (strong, nonatomic)  UILabel *emptyLabel;

@property (strong, nonatomic) PMActivityDelegate* delegateInstance;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _allImages = [[NSMutableArray alloc] init];
    self.title = @"Cloud";
    
    
    if ([PFUser currentUser]) {
        [self loadAndCacheObjects];
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
            
            if ([PFUser currentUser])
                
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"No photos to display"]]];
            else
                [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are not connected"]]];
            
            [self.view addSubview:_emptyLabel];
            
        } else
            if (_emptyLabel) {
                [_emptyLabel removeFromSuperview];
                _emptyLabel = nil;
            }
    } else
        //if not logged in
        if (![PFUser currentUser]) {
            if (_emptyLabel) {
                [_emptyLabel removeFromSuperview];
            }
            if (!_emptyLabel) {
                _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
                _emptyLabel.backgroundColor = [UIColor clearColor];
                [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
            }
            
            [_emptyLabel setAttributedText:[self attributedStringForText:[NSString stringWithFormat:@"You are not connected"]]];
            [self.view addSubview:_emptyLabel];
        }
    
}
- (void) loadAndCacheObjects {
  
    [self showHUD];
    
    cloudRefresh(_allImages, dispatch_get_main_queue(), ^(NSMutableArray *allPhotos) {
        
        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!_cachedImages) {
                _cachedImages = [NSCache new];
            }
            
            _cachedImages.countLimit = 100;
            [_cachedImages setName:@"cloudCache"];
            [_cachedImages setTotalCostLimit:(5 * 1024 * 1024)];//5MB
            [_cachedImages setEvictsObjectsWithDiscardedContent:YES];
            
            [allPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                PFFile *theImage = [(PFObject*)obj objectForKey:@"smallImageFile"];
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    
                    NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                    
                    NSNumber *index = [NSNumber numberWithInteger:idx];
                    [_cachedImages setObject:purgeableData forKey:index cost:data.length];
                    
                }];
            }];
                
            _imagesArrayDidChange = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                if (refreshHUD) {
                    [refreshHUD hide:YES];
                    refreshHUD = nil;
                }
                [self showEmptyLabel];
                
            });
            
            
        }); //end of dispatch
        
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
        refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        
        // Set custom view mode
        refreshHUD.mode = MBProgressHUDModeCustomView;
       
        [self.view addSubview:refreshHUD];
        [self showEmptyLabel];
    }

    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
        
    
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
    [self.refreshBtn setEnabled:NO];
    _imagesArrayDidChange = NO;

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
            
            [self.refreshBtn setEnabled:YES];
        } else {
            if (_imagesArrayDidChange) {
                [self.collectionView reloadData];
                _imagesArrayDidChange = NO;
            }
            [self showEmptyLabel];
        }
    } else
        [self clearCollectionView];
    
    
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_allImages) {
        return 1;
    } else
        return 0;
    
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSLog(@"all images count - %d", _allImages.count);
    return [_allImages count];
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
    NSPurgeableData *imageData = [_cachedImages objectForKey:index];

    
        if (!imageData) {
            
            PFObject *eachObject = [_allImages objectAtIndex:indexPath.row];
            PFFile *theImage = [eachObject objectForKey:@"imageFile"];
            
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0UL);
                dispatch_async(queue, ^{
                    NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = [UIImage imageWithData:purgeableData];
                        [cell setNeedsLayout];
                    });
                    [_cachedImages setObject:purgeableData forKey:index cost:data.length];
                    [imageData endContentAccess];
                    [imageData discardContentIfPossible];

                });
                    
            }];

            
        } else
    
            if ([imageData beginContentAccess]) {
                imageView.image = [UIImage imageWithData:imageData];
                [imageData endContentAccess];
                [imageData discardContentIfPossible];
                [cell setNeedsLayout];
            }
    
    return cell;
    
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

#pragma mark -  IBAction buttons pressed
- (IBAction)cloudRefresh:(id)sender {
    if ([PFUser currentUser]) {
        [self loadAndCacheObjects];
    }
    
}

- (IBAction)actionButton:(id)sender {
    
    if (!_delegateInstance) {
        _delegateInstance = [[PMActivityDelegate alloc] init];
    }
    
    _activityDelegate = _delegateInstance;
    
    if ([_activityDelegate respondsToSelector:@selector(showActivitySheet:)]) {
        [_activityDelegate showActivitySheet:self];
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


#pragma mark - PFLogInViewControllerDelegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}



#pragma mark - UIViewControllerTransitioningDelegate NOT USED
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

#pragma mark - AtrributedString method
-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor lightGrayColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0]} range:range];
    
    return attrMutableString;
}



@end
