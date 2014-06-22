//
//  PMFunctions.m
//  Photoconsent
//
//  Created by Alex Rafferty on 08/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMFunctions.h"
#import <Parse/Parse.h>
#import "PMAppDelegate.h"


@implementation PMFunctions 



UIImage* resizeImage(UIImage *imageIn, CGSize itemSize ) {
    
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [imageIn drawInRect:imageRect];
    return UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}


void cloudPhoto(UIImage *image,NSString* reference,
                dispatch_queue_t queue, void (^block)(id userPhoto))
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Resize image and start consent process
        NSData *imageData = UIImageJPEGRepresentation(resizeImage(image, CGSizeMake(640.0, 960.0)), 1.0f);
        PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
        // create a new userphoto and set image, user and user permissions
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
        [userPhoto setObject:imageFile forKey:@"imageFile"];
        
        NSData *smallImageData = UIImageJPEGRepresentation(resizeImage(image, CGSizeMake(79.0, 82.0)), 1.0f);
        PFFile *smallImageFile = [PFFile fileWithName:@"SmallImage.jpg" data:smallImageData];
        [userPhoto setObject:smallImageFile forKey:@"smallImageFile"];
        
        
        
        userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        PFUser *user = [PFUser currentUser];
        [userPhoto setObject:user forKey:@"user"];
        [userPhoto setObject:reference forKey:@"referenceID"];
        
        //return the userPhoto in the completion block
        dispatch_async(queue, ^{
            block(userPhoto);
        });
        
    });
}



#pragma mark - add watermark

UIImage* generateWatermarkForImage(UIImage *mainImg) {
    UIImage *backgroundImage = mainImg;
    UIImage *watermarkImage = [UIImage imageNamed:@"iconwatermark"];
    
    
    //Now re-drawing your  Image using drawInRect method
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    // set watermark position/frame a s(xposition,yposition,width,height)
    [watermarkImage drawInRect:CGRectMake((backgroundImage.size.width - watermarkImage.size.width) / 2, (backgroundImage.size.height - watermarkImage.size.height) / 2, watermarkImage.size.width - 20., watermarkImage.size.height)];
    
    // now merging two images into one
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

BOOL isPaid() {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isPaid = [defaults valueForKey:@"Paid"];
    return [isPaid boolValue];
    
}


BOOL reachable() {
    
    //Reachability
    PMAppDelegate *appDelegate = (PMAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isParseReachable]) {
        return YES;
    } else {
    
        NSError *error = createErrorWithMessage(@"The server is not reachable", @300);
        dispatch_async(dispatch_get_main_queue(), ^{
            showConnectionError(error);
            
        });
        
        return NO;
    }
}


void showConnectionError(NSError* error) {

    NSString *errorLocalizedString  = [error localizedDescription];
    UIAlertView *showError = [[UIAlertView alloc] initWithTitle:@"The internet connection appears to be offline" message: errorLocalizedString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [showError show];
  }



dispatch_source_t connectionTimer() {
    //returns a timer that fires the eventHandlerBlock every 10 seconds
    
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, startTime, 10 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    return timer;

    
}


PFQuery* refreshQuery() {
    // create a PFQuery
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
    [query orderByAscending:@"createdAt"];
    query.limit = 400;
    return query;
    
}

void cloudRefresh(PFQuery* query,NSMutableArray* allImages,id<UIAlertViewDelegate> alertviewDelegate,void (^block)(NSMutableArray *allPhotos, NSError *queryError))
{
    
    PMAppDelegate *appDelegate = (PMAppDelegate*)[[UIApplication sharedApplication] delegate];
    //connection is reachable so start processing the query
    //start a timer to check every 10 seconds if save still processing
    dispatch_source_t timeoutTimer = connectionTimer();
    [appDelegate setTimeoutTimer:timeoutTimer];
    
    
    dispatch_source_set_event_handler(timeoutTimer, ^{
        
        //no connection give user the option to cancel
        dispatch_suspend(timeoutTimer);
        NSString *errorLocalizedString  = @"Do you want to continue?";
        UIAlertView *showTimeOutOption = [[UIAlertView alloc] initWithTitle:@"The connection may be lost or intermittent" message: errorLocalizedString delegate:alertviewDelegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        showTimeOutOption.tag = 3;
        [showTimeOutOption show];
        
        
    });
    
    
    dispatch_source_set_cancel_handler(timeoutTimer, ^{
        
        [appDelegate setTimeoutTimer:nil];
    });
    
    dispatch_resume(timeoutTimer);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            dispatch_source_cancel(timeoutTimer);
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
            
            block(allImages, error);
           
        }];
        
    });
    
}

NSError* createErrorWithMessage(NSString *message, NSNumber *code) {
    
    //create and return a custom error object
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message,@"code":code};
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:code.integerValue userInfo:userInfo];
    return error;
}




@end
