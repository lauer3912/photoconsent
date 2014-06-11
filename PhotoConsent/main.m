//
//  main.m
//  Photoconsent
//
//  Created by Edward Wallitt on 24/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerifyStoreReceipt.h"

#import "PMAppDelegate.h"

int main(int argc, char *argv[])
{
    
    /*
     if the local receipt is found and the transaction has not been cancelled
     the function will set the user defualt
     
    */
    localReceiptSubscriptionIsCancelled();
    
    
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PMAppDelegate class]));
    }
}
