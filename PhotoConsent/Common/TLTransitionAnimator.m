//
//  TLTransitionAnimator.m
//  
//
//  Created by Alex Rafferty on 29/11/2013.
//  Copyright (c) 2013 RMS. All rights reserved.
//

#import "TLTransitionAnimator.h"

@implementation TLTransitionAnimator- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    CGRect endFrame = CGRectMake(0, 0.0, 320, 480);
    
    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = CGRectMake(0, 480., 320.0, 0);
        startFrame.origin.x += 0;
        
        toViewController.view.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        endFrame.origin.x += 300;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0. usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = endFrame;
            
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
         }];
        
       
    }
}




@end
