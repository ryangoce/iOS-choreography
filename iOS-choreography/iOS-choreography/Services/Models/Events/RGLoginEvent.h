//
//  RGLoginEvent.h
//  
//
//  Created by Ryan Goce on 10/15/15.
//
//

#import <Foundation/Foundation.h>
#import "RGUser.h"

#define kRGLoginEvent     @"kRGLoginEvent"

@interface RGLoginEvent : NSObject

@property (nonatomic, strong) RGUser *user;
@property (nonatomic) BOOL isCanceled;
@property (nonatomic, readonly) NSError *error;

@end
