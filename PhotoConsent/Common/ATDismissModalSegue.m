//
//  ATDismissModalSegue.m
//  GAS
//
//  Created by Alex Rafferty on 23/11/2012.
//  Copyright (c) 2012 Ability Technology Group. All rights reserved.
//

#import "ATDismissModalSegue.h"

@implementation ATDismissModalSegue


- (void) perform {
    
        UIViewController * svc = self.sourceViewController;

       [svc.presentingViewController dismissViewControllerAnimated:YES completion:^{
           
           
          
       }];
    
}

@end
