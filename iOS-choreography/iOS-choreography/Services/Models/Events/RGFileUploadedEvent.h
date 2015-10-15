//
//  RGFileUploadedEvent.h
//  
//
//  Created by Ryan Goce on 10/15/15.
//
//

#import <Foundation/Foundation.h>

#define kFileUploadedEvent  @"kFileUploadedEvent"

@interface RGFileUploadedEvent : NSObject

@property (nonatomic, strong) NSString *uploadId;

@end
