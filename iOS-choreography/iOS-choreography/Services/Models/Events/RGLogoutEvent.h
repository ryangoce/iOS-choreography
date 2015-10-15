//
//  RGLogoutEvent.h
//  
//
//  Created by Ryan Goce on 10/15/15.
//
//

#import <Foundation/Foundation.h>
#import "RGUser.h"

#define kRGLogoutEvent    @"kRGLogoutEvent"

@interface RGLogoutEvent : NSObject

@property (nonatomic, strong) RGUser *user;
@property (nonatomic) BOOL isCanceled;

@end
