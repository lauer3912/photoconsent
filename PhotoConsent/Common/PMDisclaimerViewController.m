//
//  PMDisclaimerViewController.m
//  Photoconsent
//
//  Created by Alex Rafferty on 06/01/2014.
//  Copyright (c) 2014 Podmedics. All rights reserved.
//

#import "PMDisclaimerViewController.h"
#import "PMTextConstants.h"

@interface PMDisclaimerViewController ()

@end

@implementation PMDisclaimerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   [ _disclaimerTextView setAttributedText:[self attributedStringForText:kPMTextConstants_Disclaimer]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)disclaimer:(id)sender {
    
    NSDate *date;
    NSNumber *disclaimerAcknowledged;
    if ([[(UIBarButtonItem*)sender title] isEqualToString:@"Accept"]) {
        date = [NSDate date];
        disclaimerAcknowledged = [NSNumber numberWithBool:YES];
    } else {
        date = [NSDate distantFuture];
        disclaimerAcknowledged = [NSNumber numberWithBool:NO];

    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString* formatString =  [NSDateFormatter dateFormatFromTemplate:@"EdMMMhh:mma" options:0 locale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:formatString];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:disclaimerAcknowledged forKey:@"disclaimerAcknowledged"];
        [defaults setValue:[dateFormatter stringFromDate:date] forKey:@"disclaimerAcknowledgedDate"];
       
    }];
    
    
}

-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkTextColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}

@end
