//
//  NSString+Extensions.m
//  jumpstart
//
//  Created by Ryan Goce on 10/8/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

@end
