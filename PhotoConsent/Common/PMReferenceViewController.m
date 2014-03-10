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
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"disclaimer"]) {
        [segue.destinationViewController setTitle:@"Disclaimer"];

    }
    
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


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    
        
    if (section == 0) {
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 240.0, 50.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        [stringLabel setTextAlignment:NSTextAlignmentCenter];
        [stringLabel setNumberOfLines:2];
        NSString *string = [NSString stringWithFormat:@"Refer to details"];
       
        NSAttributedString *attrString = [self attributedStringForText:string];
        [stringLabel setAttributedText:attrString];
        [headerView addSubview:stringLabel];
    }
    
        
       return headerView;
}

-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = self.view.tintColor;
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}



@end
