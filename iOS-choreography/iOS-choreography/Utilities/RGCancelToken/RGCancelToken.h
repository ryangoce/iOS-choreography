//
//  RGCancelToken.h
//  Sensoria
//
//  Created by Ryan Goce on 6/4/14.
//  Copyright (c) 2014 Saperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RGCancelTokenRequestCancellationBlock)(void);

@interface RGCancelToken : NSObject

@property (nonatomic, copy) RGCancelTokenRequestCancellationBlock cancellationRequestedBlock;

@property (nonatomic, readonly) BOOL isCanceled;

@end
