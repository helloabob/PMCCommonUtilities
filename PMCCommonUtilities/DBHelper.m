//
//  DBHelper.m
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-13.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import "DBHelper.h"

#import <sqlite3.h>

sqlite3 *contactDB;

static DBHelper *_sharedInstance = nil;

static int _autocrement_task_id = 1;

@interface DBHelper () {
    NSMutableArray *_tasks;
    BOOL thread_flag;
    NSString *_DBPath;
    NSThread *thread_;
}

@end

@implementation DBHelper


- (void)setDBPath:(NSString *)DBPath {
    if (![_DBPath isEqualToString:DBPath]) {
        [_DBPath release];
        _DBPath = nil;
        _DBPath = [DBPath retain];
        thread_flag = true;
        if (_tasks == nil) {
            _tasks = [[NSMutableArray alloc] init];
        }
        if (thread_ == nil) {
//            thread_ = [[NSThread alloc] initWithTarget:self selector:@selector(thread_job) object:nil];
//            [thread_ start];
        }
    }
}
+ (id)sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[DBHelper alloc] init];
        
    }
    return _sharedInstance;
}

- (void)thread_job {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    while (thread_flag) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        if (_tasks.count > 0) {
            DBProcessTask *task = [_tasks objectAtIndex:0];
            [self doTask:task];
            [[NSNotificationCenter defaultCenter] postNotificationName:task.notificationName object:nil userInfo:[NSDictionary dictionaryWithObject:task forKey:@"task"]];
            [_tasks removeObject:task];
        } else {
            _autocrement_task_id = 1;
            sleep(1);
        }
        [pool2 drain];
    }
    
    [pool drain];
}

- (int)addTask:(DBProcessTask *)task {
    task.taskID = _autocrement_task_id++;
    [_tasks addObject:task];
    return task.taskID;
}

- (void)doTask:(DBProcessTask *)task {
    if (task.taskType == TaskCreateTable) {
        [self doCreateTableJob:task];
    } else if(task.taskType == TaskExecCommand) {
        [self doCreateTableJob:task];
    } else if(task.taskType == TaskQueryData) {
        [self doQueryJob:task];
    }
}

- (void)doQueryJob:(DBProcessTask *)task {
    const char *dbpath = [_DBPath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = task.sql;
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            task.resultCollection = [NSMutableArray array];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                int dataCount = sqlite3_column_count(statement);
                for (int i = 0; i <dataCount; i++) {
                    char *rowdata = (char *)sqlite3_column_text(statement, i);
                    if (rowdata != nil) {
                        NSString *tmpStr = [NSString stringWithCString:rowdata encoding:NSUTF8StringEncoding];
                        [tmpArray addObject:tmpStr];
                    }
                }
                [task.resultCollection addObject:tmpArray];
                [tmpArray release];
            }
            sqlite3_finalize(statement);
        }
        task.resultCode = 1;
        sqlite3_close(contactDB);
    } else {
        sqlite3_close(contactDB);
        task.resultCode = -1;
        task.errorCode = @"无法加载数据库";
    }
}

- (void)doExecCommandJob:(DBProcessTask *)task {
    sqlite3_stmt *statement;
    
    const char *dbpath = [_DBPath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        NSString *insertSQL = task.sql;
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            task.resultCode = 1;
        }
        else
        {
            task.errorCode = @"保存失败";
            task.resultCode = -1;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    } else {
        task.errorCode = @"无法加载数据库";
        task.resultCode = -1;
    }
}

- (void)doCreateTableJob:(DBProcessTask *)task {
    const char *dbpath = [_DBPath UTF8String];
//    NSLog(@"a");
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK)
    {
//        NSLog(@"b");
        char *errMsg;
        const char *sql_stmt = [task.sql UTF8String];
        if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            task.errorCode = @"执行失败\n";
            task.resultCode = -1;
//            return false;
        } else {
//            printf("success:%s",sql_stmt);
            task.resultCode = 1;
        }
        sqlite3_close(contactDB);
    }
    else
    {
        task.errorCode = @"创建/打开数据库失败";
        task.resultCode = -1;
//        return NO;
    }
//    task.errorCode = @"code";
    
//    return true;
}

@end
