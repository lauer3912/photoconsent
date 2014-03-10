//
//  PMSubjectProvider.h
//  PhotoConsent
//
//  Created by Alex Rafferty on 25/01/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMSubjectProvider : UIActivityItemProvider

@property (strong,nonatomic) UIActivityViewController* activityViewController;


-(id)item;

@end
