//
//  TLTransitionAnimator.m
//  DummyViewTransition
//
//  Created by Alex Rafferty on 29/11/2013.
//  Copyright (c) 2013 RMS. All rights reserved.
//

#import "TLTransitionAnimator.h"

@implementation TLTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.1f;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    
    if (self.presenting) {
       
        CGRect endFrame =  fromViewController.view.frame; 
       
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = CGRectMake(0., 0., 320.0, 0.);
        

        toViewController.view.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = endFrame;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        

        CGRect endFrame = CGRectMake(0, 0., 320, 0.);
        
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        
        
        [UIView animateWithDuration:0.1f animations:^{
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = endFrame;
            
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
         }];
        
       
    }
}




@end
