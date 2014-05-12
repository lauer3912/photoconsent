//
//  PMReferenceViewController.m
//  Photoconsent
//
//  Created by Alex Rafferty on 10/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMReferenceViewController.h"
#import "PMReferenceDetail.h"


@interface PMReferenceViewController ()
 
@end

@implementation PMReferenceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
//    [self.view setBackgroundColor:[UIColor turquoise]];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"assessment"]) {
        [segue.destinationViewController setTitle:@"Assessment"];
        
    }
    if ([segue.identifier isEqualToString:@"education"]) {
        [segue.destinationViewController setTitle:@"Education"];
        
    }
    if ([segue.identifier isEqualToString:@"publication"]) {
        [segue.destinationViewController setTitle:@"Publication"];
        
    }

    
}



- (IBAction)closeReferenceForm:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [_activity activityDidFinish:YES];
    }];
}


-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = self.view.tintColor;
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}



@end
