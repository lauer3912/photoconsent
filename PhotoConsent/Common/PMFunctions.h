//
//  PMFunctions.h
//  Photoconsent
//
//  Created by Alex Rafferty on 08/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFFile, PFQuery;

@interface PMFunctions : NSObject 

extern UIImage* resizeImage(UIImage *imageIn, CGSize itemSize );

extern void cloudPhoto(UIImage *image,NSString* reference,
                       dispatch_queue_t queue, void (^block)(id userPhoto));

extern UIImage* generateWatermarkForImage(UIImage *mainImg);

extern BOOL isPaid();

extern void showConnectionError(NSError* error);

extern dispatch_source_t startConnectionTimer (void (^handlerBlock)());


extern PFQuery* refreshQuery();

extern void cloudRefresh(PFQuery* query,NSMutableArray* allImages,id<UIAlertViewDelegate> alertviewDelegate, void (^block)(NSMutableArray *allPhotos, NSError *queryError));

extern NSError* createErrorWithMessage(NSString *message, NSNumber *code);

@end
