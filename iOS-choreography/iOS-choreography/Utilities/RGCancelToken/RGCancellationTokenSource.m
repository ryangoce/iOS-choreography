//
//  RGCancellationTokenSource.m
//  Sensoria
//
//  Created by Ryan Goce on 6/4/14.
//  Copyright (c) 2014 Saperium Inc. All rights reserved.
//

#import "RGCancellationTokenSource.h"

@interface RGCancelToken (RGCancellationTokenSource)

@property (nonatomic) BOOL isCanceled;

@end

@interface RGCancellationTokenSource ()

@property (nonatomic, strong) RGCancelToken *token;

@end

@implementation RGCancellationTokenSource


-(RGCancelToken *)token {
    if (_token == nil) {
        _token = [RGCancelToken new];
    }
    return _token;
}

-(void)cancel {
    if (self.token.cancellationRequestedBlock) {
        self.token.cancellationRequestedBlock();
        self.token.isCanceled = YES;
    }
}

@end
