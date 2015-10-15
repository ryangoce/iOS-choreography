//
//  RGLoginViewController.h
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGLoginViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *buttonLogin;
@property (nonatomic, weak) IBOutlet UITextField *textUsername;
@property (nonatomic, weak) IBOutlet UITextField *textPassword;

-(IBAction)tappedLogin:(UIButton *)sender;

@end
