//
//  RGUploadService.h
//  jumpstart
//
//  Created by Ryan Goce on 10/8/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGService.h"
#import "RGUser.h"
#import "RGCancellationTokenSource.h"

@interface RGUploadService : RGService

+ (RGUploadService *)sharedInstance;

-(void)uploadFileFrom:(NSURL *)fromUrl toUrl:(NSURL *)toUrl withId:(NSString **)uploadId cancelToken:(RGCancelToken *)cancelToken;

@end
