//
//  RMCustomSegue.m
//  DummyViewTransition
//
//  Created by Alex Rafferty on 29/11/2013.
//  Copyright (c) 2013 RMS. All rights reserved.
//

#import "RMCustomSegue.h"

@implementation RMCustomSegue


- (void) perform {
    
    if ([self.identifier isEqualToString:@"showPanel"]) {
        UIViewController *detailViewController = self.destinationViewController;
        
        detailViewController.transitioningDelegate = self.sourceViewController;
        detailViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self.sourceViewController presentViewController:detailViewController animated:YES completion:^{
            
        }];
    } else {
        UIViewController * svc = self.sourceViewController;
        
        [svc.presentingViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}


@end
