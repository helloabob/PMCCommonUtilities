//
//  DBProcessTask.h
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-13.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TaskCreateTable,
    TaskQueryData,
    TaskExecCommand,
}TaskType;

@interface DBProcessTask : NSObject {
}

@property (nonatomic, assign) int               taskID;
@property (nonatomic, strong) NSString          *sql;
@property (nonatomic, strong) NSArray           *params;
@property (nonatomic, strong) NSString          *notificationName;
@property (nonatomic, assign) TaskType          taskType;
@property (nonatomic, strong) NSString          *errorCode;
@property (nonatomic, assign) int               resultCode;
@property (nonatomic, strong) NSMutableArray    *resultCollection;

@end
