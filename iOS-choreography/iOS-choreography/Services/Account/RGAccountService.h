//
//  RGAccountService.h
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGService.h"
#import "RGCancellationTokenSource.h"
#import "RGUser.h"




@interface RGAccountService : RGService

+ (RGAccountService *)sharedInstance;

@property (nonatomic, readonly) RGUser *loggedinUser;

-(void)loginUser:(RGUser *)user withCancelToken:(RGCancelToken *)cancelToken;
-(void)logout;

@end
