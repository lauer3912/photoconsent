//
//  PMUpgradeViewController.m
//  PhotoConsent
//
//  Created by Alex Rafferty on 17/03/2014.
//  Copyright (c) 2014 PM. All rights reserved.
//

#import "PMUpgradeViewController.h"

@interface PMUpgradeViewController ()


@property (weak, nonatomic) IBOutlet UILabel  *productName;
@property (weak, nonatomic) IBOutlet UILabel  *productDesc;
@property (weak, nonatomic) IBOutlet UILabel  *productPrice;
@property (weak, nonatomic) IBOutlet UIButton  *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton  *renewButton;

@end

@implementation PMUpgradeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIColor *orange = [UIColor colorWithRed:1.0 green:140.0/255.0 blue:0 alpha:1.0];
        
        [_upgradeButton setBackgroundColor:orange];
       
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     UIColor *turquoise = [UIColor colorWithRed:64./255.0 green:224.0/255.0 blue:208.0/255.0 alpha:1.0];
    [self.view setBackgroundColor:turquoise];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
