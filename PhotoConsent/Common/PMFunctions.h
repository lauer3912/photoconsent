//
//  PMFunctions.h
//  Photoconsent
//
//  Created by Alex Rafferty on 08/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMFunctions : NSObject  

extern UIImage* resizeImage(UIImage *imageIn, CGSize itemSize );

extern void cloudPhoto(UIImage *image,NSString* reference,
                       dispatch_queue_t queue, void (^block)(id userPhoto));

@end
