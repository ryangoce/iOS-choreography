//
//  RGUploadService.m
//  jumpstart
//
//  Created by Ryan Goce on 10/8/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGUploadService.h"
#import "RGService+Protected.h"
#import "NSString+Extensions.h"
#import "RGLoginEvent.h"
#import "RGLogoutEvent.h"
#import "RGFileUploadedEvent.h"

@interface RGUploadService ()


@end

@implementation RGUploadService

#pragma mark - init
-(instancetype)init {
    self = [super init];
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
    RGLoginEvent *loginEvent = notif.object;
    [self startAllUploadsForUser:loginEvent.user];
}

#pragma mark - RGLogutEvent
-(void)logoutEventFired:(NSNotification *)notif {
    [self stopAllUploads];
}

#pragma mark - Shared Instance
static RGUploadService *sharedInstance;
+ (RGUploadService *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[RGUploadService alloc]init];
    });
    
    return sharedInstance;
}

#pragma mark - private
-(void)startAllUploadsForUser:(RGUser *)user {
    [self scheduleBlock:^{
        //TODO: Do actual upload
        sleep(5);
    }];
}

-(void)stopAllUploads {
    [self scheduleBlock:^{
        //TODO: Do actual stop
        sleep(1);
    }];
}

#pragma mark - public
-(void)uploadFileFrom:(NSURL *)fromUrl toUrl:(NSURL *)toUrl withId:(NSString *__autoreleasing *)uploadId cancelToken:(RGCancelToken *)cancelToken {
    
    //assign the unique id first
    NSString *uuid = [NSString uuid];
    *uploadId = uuid;
    
    [self scheduleBlock:^{
        //TODO: Do actual stop
        
        sleep(3);
        
        //successfully uploaded the file
        RGFileUploadedEvent *fileUploadedEvent = [RGFileUploadedEvent new];
        fileUploadedEvent.uploadId = uuid;
        
        NSNotification *notif = [NSNotification notificationWithName:kRGLoginEvent object:fileUploadedEvent     userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notif];
    }];
}


@end
