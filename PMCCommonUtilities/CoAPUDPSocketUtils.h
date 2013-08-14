//
//  CoAPUDPSocketUtils.h
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-14.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoAPUDPSocketUtils : NSObject

+ (NSString *)sendMessageWithData:(NSData *)data withIP:(NSString *)ip isResponse:(BOOL)isResponse;

@end
