//
//  RGCancellationTokenSource.h
//  Sensoria
//
//  Created by Ryan Goce on 6/4/14.
//  Copyright (c) 2014 Saperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGCancelToken.h"

@interface RGCancellationTokenSource : NSObject

@property (nonatomic, readonly) RGCancelToken *token;

-(void)cancel;

@end
