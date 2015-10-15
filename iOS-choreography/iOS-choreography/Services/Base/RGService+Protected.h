//
//  RGService+Protected.h
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "RGService.h"

@interface RGService (Protected)

-(void)scheduleBlock:(dispatch_block_t)block;

-(void)executeBlock:(dispatch_block_t)block;

@end
