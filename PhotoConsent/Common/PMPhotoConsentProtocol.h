//
//  PMPhotoConsentProtocol.h
//  Photoconsent
//
//  Created by Alex Rafferty on 19/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PMPhotoConsentProtocol <NSObject>

@optional
- (void) startCamera:(id) sender;
- (void) showActivitySheet:(id) sender;

@end
