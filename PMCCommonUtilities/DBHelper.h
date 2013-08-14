//
//  DBHelper.h
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-13.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBProcessTask.h"

@interface DBHelper : NSObject

+ (id)sharedInstance;

- (void)setDBPath:(NSString *)DBPath;

- (int)addTask:(DBProcessTask *)task;

- (void)doTask:(DBProcessTask *)task;

@end
