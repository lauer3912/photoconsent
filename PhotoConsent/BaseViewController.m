//
//  BaseViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//
// Modified January 2014 by Podmedics (Alex Rafferty)
//
//

#import "BaseViewController.h"
#import "PMAppDelegate.h"
#import "PMCameraDelegate.h"
#import "MyPageViewController.h"
#import "PMLoginActivityDelegate.h"


@interface BaseViewController ()
@property (strong, nonatomic) PMCameraDelegate* delegateInstance;
@property (strong, nonatomic) PMLoginActivityDelegate* loginActivityDelegate;
@end

@implementation BaseViewController

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController* viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithOptions:(NSDictionary *)options {
    UIImage *buttonImage = [UIImage imageNamed:options[@"buttonImage"]];
    UIImage *highlightImage = [UIImage imageNamed:options[@"highlightImage"]];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    UITabBarItem *item = [self.tabBar.items objectAtIndex:1];
    item.enabled = YES;
    
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button setContentMode:UIViewContentModeCenter];
    [button addTarget:self action:@selector(centerItemTapped) forControlEvents:UIControlEventTouchUpInside];
        
    CGSize tabbarSize = self.tabBar.bounds.size;
    CGPoint center = CGPointMake(tabbarSize.width/2, tabbarSize.height/2);
    center.y = center.y - 9.5;
    button.center = center;
    button.tag = 27;
    
    [self.tabBar addSubview:button];
    
}



#pragma mark - loginAlert alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
    
    
    }
}

- (void)centerItemTapped {
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera] == YES){
        
        
        if (self.selectedIndex == 1) {
            if (![PFUser currentUser]) {
                if (!_loginActivityDelegate) 
                    _loginActivityDelegate = [[PMLoginActivityDelegate alloc] init];
                
                
                _activityDelegate = _loginActivityDelegate;
                
                if ([_activityDelegate respondsToSelector:@selector(showActivitySheet:)])
                    [_activityDelegate showActivitySheet:self];
                
            }
            
        }
        
        if (!_delegateInstance) {
            _delegateInstance = [[PMCameraDelegate alloc] init];
        }
        _cameraDelegate = _delegateInstance;

          if ([_cameraDelegate respondsToSelector:@selector(startCamera:)]) {
         //determine the currently selected tab on tabbar. If user is scrolling through individual photos pop back to root viewcontroller before sending the viewcontroller to the camera delegate
            
            UINavigationController *navController = (UINavigationController*)self.selectedViewController;
        
            if ([navController.topViewController isKindOfClass:[MyPageViewController class]]) {
                [navController popToRootViewControllerAnimated:NO];
            }
         
            
            [_cameraDelegate startCamera:navController.topViewController];
            
            
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry but this device does not have a camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
