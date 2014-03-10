//
//  TLTransitionAnimator.h
//  DummyViewTransition
//
//  Created by Alex Rafferty on 29/11/2013.
//  Copyright (c) 2013 RMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLTransitionAnimator : NSObject  <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
