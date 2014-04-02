//
//  PMFeedbackActivity.h
//  Photoconsent
//
//  Created by Alex Rafferty on 30/12/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PMFeedbackActivity : UIActivity

enum PMFeedbackActivityShareType: NSInteger {
    
    shareActivityTypeFeedback,
    shareActivityTypePromote,
    shareActivityTypeWithImages,
    
};
typedef enum PMFeedbackActivityShareType PMFeedbackActivityShareType;

@property (strong, nonatomic) id senderController;
@property (assign, nonatomic) PMFeedbackActivityShareType shareActivityType;

- (id) initWithSenderController:(UIViewController*)controller shareActivityType:(PMFeedbackActivityShareType)shareActivityType;


@end
