//
//  PMFunctions.m
//  Photoconsent
//
//  Created by Alex Rafferty on 08/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMFunctions.h"
#import <Parse/Parse.h>


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
        
        NSData *smallImageData = UIImageJPEGRepresentation(resizeImage(image, CGSizeMake(65.0, 65.0)), 1.0f);
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



@end
