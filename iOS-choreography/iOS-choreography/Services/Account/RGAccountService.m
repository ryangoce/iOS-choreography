//
//  RGAccountService.m
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGAccountService.h"
#import "RGService+Protected.h"
#import "RGLoginEvent.h"
#import "RGLogoutEvent.h"

//error definitions
//error domain name
#define ERROR_DOMAIN @"com.saperium.jumpstart"

//error codes. RGAccountService is assigned the 100 series for codes
#define ERROR_CODE_LOGIN_CANCELED   100


@interface RGAccountService ()

@property (nonatomic, strong) RGUser *loggedinUser;

@end

@implementation RGAccountService


#pragma mark - Shared Instance
static RGAccountService *sharedInstance;
+ (RGAccountService *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[RGAccountService alloc]init];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)loginUser:(RGUser *)user withCancelToken:(RGCancelToken *)cancelToken {
    [self scheduleBlock:^{
        
        if (cancelToken) {
            cancelToken.cancellationRequestedBlock = ^() {
                //TODO: Handle when user cancels the login
            };
        }
        
        //simulate a HTTP call by sleeping
        sleep(1.5);
        
        if (!cancelToken.isCanceled) {
            
            //set the logged in user
            self.loggedinUser = user;
            
            //successfully logged in the user
            RGLoginEvent *loginEvent = [RGLoginEvent new];
            loginEvent.user = user;
            
            NSNotification *notif = [NSNotification notificationWithName:kRGLoginEvent object:loginEvent userInfo:nil];
            [[NSNotificationCenter defaultCenter]postNotification:notif];
        }
        
    }];
}

-(void)logout {
    [self scheduleBlock:^{
        
        RGLogoutEvent *logoutEvent = [RGLogoutEvent new];
        logoutEvent.user = self.loggedinUser;
        
        NSNotification *notif = [NSNotification notificationWithName:kRGLogoutEvent object:logoutEvent userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notif];
        
        //set loggedinUser to nil
        self.loggedinUser = nil;
    }];
}


@end
