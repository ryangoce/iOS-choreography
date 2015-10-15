//
//  RGService.h
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGService : NSObject
{
    
@protected
    dispatch_queue_t _serviceQueue;
    void *_serviceQueueTag;
    id _sharedInstance;
}

@end