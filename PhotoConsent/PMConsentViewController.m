//
//  PMConsentViewController.m
//  Photoconsent
//
//  Created by Edward Wallitt on 27/02/2013.
//  Copyright (c) 2013 Podmedics. All rights reserved.
//

#import "PMConsentViewController.h"
#import "PMFunctions.h"
#import "PMPurposeViewController.h"


@interface PMConsentViewController ()

@end

@implementation PMConsentViewController

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
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender {
    //important to end the activity
    [_activityConsent activityDidFinish:YES];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 )
        return  1;
    else
        return 3;
}

#pragma mark - tableview delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __block NSString* dateString;
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"consentCell"];
    if (indexPath.section == 0) {
        [cell setUserInteractionEnabled:NO];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(140.0, 40.0, 140.0, 65.0)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 115.0, 120.0)];
        //imageView of photo

        if ([_m_selectedPhoto isKindOfClass:[PFObject class]]) {
            
                //get the image using Parse background block
                PFFile *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
                
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0UL);
                    
                    dispatch_async(queue, ^{
                       UIImage *image = [UIImage imageWithData:data];
                       image = resizeImage(image, iv.bounds.size);
                        
                        ////get the signature using Parse background block
                       PFFile *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
                       [signImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                          
                           dispatch_async(queue, ^{
                           
                              UIImage *signatureImage = [UIImage imageWithData:data];
                              resizeImage(signatureImage, imageView.bounds.size);
                           
                           
                              dispatch_sync(dispatch_get_main_queue(), ^{
                               imageView.image = signatureImage;
                               
                              });
                               
                           });
                           
                        }]; //end Parse getdata for signature
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            iv.image = image;
                        });
                        
                    }); //end imagefile dispatch
                    
                    
                }]; //end Parse getdata for imageFile
                
            
            
        } else {
            NSData *theImage = [_m_selectedPhoto valueForKey:@"imageFile"];
            iv.image =  resizeImage([UIImage imageWithData:theImage],iv.bounds.size);
            
            NSData *signImage = [_m_selectedPhoto valueForKey:@"consentSignature"];
            imageView.image = resizeImage([UIImage imageWithData:signImage], imageView.bounds.size);
           
            
            
        }
        
        [cell.contentView addSubview:iv];
        [cell.contentView addSubview:imageView];
        
        // show the date created
        NSDate *createdAt = [_m_selectedPhoto valueForKey:@"createdAt"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        dateString = [formatter stringFromDate:createdAt];

        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 10.0, 130.0, 20.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        [stringLabel setTextAlignment:NSTextAlignmentLeft];
        NSString *string = [NSString stringWithFormat:@"Signed  %@", dateString];
        [stringLabel setAttributedText:[self attributedStringForText:string]];
        [cell.contentView addSubview:stringLabel];
        
        
    } else
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"Assessment"];
                if ([[_m_selectedPhoto valueForKey:@"Assessment"] boolValue]) {
                    cell.userInteractionEnabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                    cell.imageView.image = [UIImage imageNamed:@"icon-check"];
                } else {
                   [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [cell.textLabel setAlpha:0.25];
                }
                
                break;
            case 1:
                [cell.textLabel setText:@"Education"];
                if ([[_m_selectedPhoto valueForKey:@"Education"] boolValue]) {
                    cell.userInteractionEnabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                    cell.imageView.image = [UIImage imageNamed:@"icon-check"];
                } else {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                     [cell.textLabel setAlpha:0.25];
                }
                break;
            case 2:
                [cell.textLabel setText:@"Publication"];
                if ([[_m_selectedPhoto valueForKey:@"Publication"] boolValue]) {
                    cell.userInteractionEnabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                     cell.imageView.image = [UIImage imageNamed:@"icon-check"];
                } else  {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                   [cell.textLabel setAlpha:0.25];
                }
                break;
            default:
                break;
        }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"purposeViewController"];
        
        [avc setModalPresentationStyle:UIModalPresentationFullScreen];
        if ([avc isKindOfClass:[PMPurposeViewController class]]) {
            [(PMPurposeViewController*)avc setPurpose:indexPath.row];
            
            [self presentViewController:avc animated:YES completion:^{
                
            }];

            
        }
        
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 4.0;
    } else
        return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 54.0;
    else
        return 22.0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView new];
    if (section == 0) {
       
        if (section == 0) {
            UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 240.0, 50.0)];
            [stringLabel setBackgroundColor:[UIColor clearColor]];
            [stringLabel setTextAlignment:NSTextAlignmentCenter];
            [stringLabel setNumberOfLines:2];
            NSString *name = [NSString stringWithFormat:@"%@",[_m_selectedPhoto valueForKey:@"patientName"]];
            NSString *email = [NSString stringWithFormat:@"%@",[_m_selectedPhoto valueForKey:@"patientEmail"]];
            NSString *string = [NSString stringWithFormat:@"%@\n%@", name, email];
            NSAttributedString *attrString = [self attributedStringForText:string];
            [stringLabel setAttributedText:attrString];
            [headerView addSubview:stringLabel];
        }
        
    } else {
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 240.0, 20.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        [stringLabel setTextAlignment:NSTextAlignmentLeft];
        [stringLabel setAttributedText:[self attributedStringForText:@"Consent to use for:" subString:@"Consent to use for:"]];
                                        
        [headerView addSubview:stringLabel];
        
    }
    return headerView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0., 320., 60.0)];
    
    
   if (section == 1) {
        NSString *reference = [_m_selectedPhoto valueForKey:@"referenceID"];
     
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0., 260., 40.0)];
        [stringLabel setBackgroundColor:[UIColor clearColor]];
        stringLabel.numberOfLines = 2;
        [stringLabel setTextAlignment:NSTextAlignmentLeft];
        [stringLabel setAttributedText:[self attributedStringForText:(NSString*)reference]];
        [footerView addSubview:stringLabel];
       
    }
    
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 & indexPath.row == 0) {
        [cell setBackgroundColor:[UIColor whiteColor]];
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 & indexPath.row == 0 ) {
        return 120.0;
    } else
        return 44.0;
}

#pragma mark - attributed string
-(NSAttributedString*) attributedStringForText: (NSString*)string {
    
    UIColor *foregroundColour = [UIColor darkTextColor];
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", string]];
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
       return attrMutableString;
}

-(NSAttributedString*) attributedStringForText: (NSString*)string subString:(NSString*)subString {
    
    NSMutableAttributedString *attrMutableString = [[NSMutableAttributedString alloc] initWithString:string];
    UIColor *foregroundColour1 = [UIColor darkTextColor];
    UIColor *foregroundColour2 = self.view.tintColor;
    
    NSRange range = [[attrMutableString string] rangeOfString:string];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour1, NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    
    range = [[attrMutableString string] rangeOfString:subString];
    [attrMutableString addAttributes:@{NSForegroundColorAttributeName: foregroundColour2,NSFontAttributeName:[UIFont systemFontOfSize:14.0]} range:range];
    
    return attrMutableString;
}

    
@end
