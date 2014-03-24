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




#pragma mark - add watermark

UIImage* generateWatermarkForImage(UIImage *mainImg) {
    UIImage *backgroundImage = mainImg;
    UIImage *watermarkImage = [UIImage imageNamed:@"iconwatermark"];
    
    
    //Now re-drawing your  Image using drawInRect method
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    // set watermark position/frame a s(xposition,yposition,width,height)
    [watermarkImage drawInRect:CGRectMake(backgroundImage.size.width - watermarkImage.size.width, backgroundImage.size.height - watermarkImage.size.height - 320.0, watermarkImage.size.width, watermarkImage.size.height)];
    
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




@end
