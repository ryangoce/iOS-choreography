//
//  RGService.m
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGService.h"
#import "RGService+Protected.h"

#import <objc/runtime.h>


@implementation RGService

-(id)init {
    self = [super init];
    
    if (self) {
        _serviceQueue = dispatch_queue_create(class_getName([self class]), NULL);
        
        _serviceQueueTag = &_serviceQueueTag;
        dispatch_queue_set_specific(_serviceQueue, _serviceQueueTag, _serviceQueueTag, NULL);
    }
    
    return self;
}

-(void)scheduleBlock:(dispatch_block_t)block {
    if (dispatch_get_specific(_serviceQueueTag)) {
        block();
    }
    else {
        dispatch_async(_serviceQueue, block);
    }
}

-(void)executeBlock:(dispatch_block_t)block {
    if (dispatch_get_specific(_serviceQueueTag)) {
        block();
    }
    else {
        dispatch_sync(_serviceQueue, block);
    }
}

@end
