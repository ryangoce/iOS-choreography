//
//  RGLoginViewController.m
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGLoginViewController.h"
#import "RGAccountService.h"
#import "RGLoginEvent.h"
#import "RGLogoutEvent.h"

@interface RGLoginViewController ()

@property (nonatomic, readonly) RGAccountService *accountService;

@end

@implementation RGLoginViewController

-(RGAccountService *)accountService {
    return [RGAccountService sharedInstance];
}

#pragma mark - init
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        //subscribe to notifications that we want to get notified
        //subscribe to login notifications
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginEventFired:) name:kRGLoginEvent object:nil];
        
        //subscribe to logout notifications
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutEventFired:) name:kRGLogoutEvent object:nil];
    }
    
    return self;
}


#pragma mark - RGLoginEvent
-(void)loginEventFired:(NSNotification *)notif {
    //dispatch this to the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        RGLoginEvent *loginEvent = notif.object;
        
        [self.activityIndicator stopAnimating];
        self.textUsername.enabled = self.textPassword.enabled = YES;
        
        if (loginEvent.error) {
            //TODO: Show alert message
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"User %@ successfully logged in!", loginEvent.user.username];
            
            [[[UIAlertView alloc]initWithTitle:@"Success!" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil]show];
            
            //TODO: show main page
        }
    });
}

#pragma mark - RGLogutEvent
-(void)logoutEventFired:(NSNotification *)notif {
    //TODO: Handle logout
}

#pragma mark - dealloc
-(void)dealloc {
    //unregister to events
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kRGLoginEvent object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kRGLogoutEvent object:nil];
}

-(void)tappedLogin:(UIButton *)sender {
    RGUser *user = [RGUser new];
    user.username = self.textUsername.text;
    user.password = self.textPassword.text;
    
    [self.accountService loginUser:user withCancelToken:nil];
    
    [self.activityIndicator startAnimating];
    self.textUsername.enabled = self.textPassword.enabled = NO;
}

@end
