//
//  PMPhotoConsentProtocol.h
//  Photoconsent
//
//  Created by Alex Rafferty on 19/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@protocol ConsentDelegate <NSObject>

@required
- (void) didCancelConsent;
- (void) didFinishSaving;

@optional
- (void) didCompleteConsentForPhoto:(PFObject*)photo;


@end

@protocol PMPhotoConsentProtocol <NSObject>

@optional

- (void) showActivitySheet:(id) sender;

@end

