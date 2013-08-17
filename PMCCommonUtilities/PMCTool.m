//
//  PMCTool.m
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-14.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import "PMCTool.h"

#import "DBProcessTask.h"

#import "DBHelper.h"

#import "CoAPUDPSocketUtils.h"

typedef enum {
    ControlResourceType,
    GetResourceInfoType,
}MessageType;

static PMCTool *_sharedInstance = nil;

@implementation PMCTool

- (NSData *)packageMessage:(NSString *)payload withType:(MessageType)type {
    char buffer[256];
    memset(buffer, 0, 256);
    if (type == ControlResourceType) {
        buffer[0] = 0x42;
        buffer[1] = 0x03;
        buffer[2] = 0x27;
        buffer[3] = 0x10;
        buffer[4] = 145;
        buffer[5] = 'l';
        buffer[6] = 1;
        buffer[7] = '0';
        
        char *point = (char *)(buffer+8);
        strcpy(point, [payload UTF8String]);
        point = NULL;
    } else {
        buffer[0] = 0x43;
        buffer[1] = 0x01;
        buffer[2] = 0x27;
        buffer[3] = 0x10;
        buffer[4] = 0x91;
        buffer[5] = 0x6C;
        buffer[6] = 0x01;
        buffer[7] = 0x30;
        
        buffer[8] = 0x01;
        buffer[9] = 0x73;
    }
    return [NSData dataWithBytes:buffer length:strlen(buffer)];
}

- (void)updateLightsForScene:(int)sceneId withData:(NSArray *)array withSceneName:(NSString *)sceneName {
    NSMutableString *mString = [NSMutableString string];
    for (NSDictionary *dict in array) {
        [mString appendFormat:@"UPDATE scene_det SET scene_bright=%d where scene_resource_id=\"%@\" and scene_det_id=%d; ",[[dict objectForKey:@"scene_bright"] intValue], [dict objectForKey:@"scene_resource_id"], sceneId];
    }
    [mString appendFormat:@"UPDATE scene_mstr set scene_name=\"%@\" where scene_id=%d;", sceneName, sceneId];
    DBProcessTask *task = [[DBProcessTask alloc] init];
    task.sql = mString;
    task.taskType = TaskExecCommand;
    [[DBHelper sharedInstance] doTask:task];
    if (task.resultCode != -1) {
        
    }
}

- (NSArray *)getLightsForScene:(int)sceneId {
    DBProcessTask *task = [[DBProcessTask alloc] init];
    task.sql = [NSString stringWithFormat:@"select light_ip,scene_bright,light_id,scene_name from light_mstr,scene_det,scene_mstr where light_id=scene_resource_id and scene_id=%d and scene_id=scene_det_id order by light_id", sceneId];
    task.taskType = TaskQueryData;
    [[DBHelper sharedInstance] doTask:task];
    if (task.resultCode != 1) {
        return nil;
    }
    return task.resultCollection;
}

- (void)changeToScene:(int)sceneId {
    NSArray *array = [self getLightsForScene:sceneId];
    for(NSArray *arr in array) {
        NSString *payload = [NSString stringWithFormat:@"{\"b\":%d}",[[arr objectAtIndex:1] intValue]];
        NSData *data = [self packageMessage:payload withType:ControlResourceType];
        [CoAPUDPSocketUtils sendMessageWithData:data withIP:[arr objectAtIndex:0] isResponse:NO];
    }
}

- (void)changeLightDimming:(int)dimming ForIP:(NSString *)ip {
    NSString *payload = [NSString stringWithFormat:@"{\"b\":%d}", dimming];
    NSData *data = [self packageMessage:payload withType:ControlResourceType];
    [CoAPUDPSocketUtils sendMessageWithData:data withIP:ip isResponse:NO];
}

- (NSArray *)getLightsInOffice {
    DBProcessTask *task = [[DBProcessTask alloc] init];
    task.sql = [NSString stringWithFormat:@"select light_ip from light_mstr where light_office_id=\"%@\" order by light_id", self.officeId];
    task.taskType = TaskQueryData;
    [[DBHelper sharedInstance] doTask:task];
    if (task.resultCode != 1) {
        return nil;
    }
    return task.resultCollection;
}

- (void)changeAllLightDimming:(int)dimming {
    NSArray *array = [self getLightsInOffice];
    for(NSArray *arr in array) {
        [self changeLightDimming:dimming ForIP:[arr objectAtIndex:0]];
//        NSString *payload = [NSString stringWithFormat:@"{\"b\":%d}", dimming];
//        NSData *data = [self packageMessage:payload withType:ControlResourceType];
//        [CoAPUDPSocketUtils sendMessageWithData:data withIP:[arr objectAtIndex:0] isResponse:NO];
    }
}

- (void)switchAllLight:(BOOL)isOn {
    DBProcessTask *task = [[DBProcessTask alloc] init];
    task.sql = [NSString stringWithFormat:@"select light_ip from light_mstr where light_office_id=\"%@\"", self.officeId];
    task.taskType = TaskQueryData;
    [[DBHelper sharedInstance] doTask:task];
    if (task.resultCode != 1) {
        return;
    }
    NSArray *array = task.resultCollection;
    for(NSArray *arr in array) {
        NSString *payload_value = isOn?@"true":@"false";
        NSString *payload = [NSString stringWithFormat:@"{\"o\":%@}", payload_value];
        NSData *data = [self packageMessage:payload withType:ControlResourceType];
        [CoAPUDPSocketUtils sendMessageWithData:data withIP:[arr objectAtIndex:0] isResponse:NO];
    }
}

+ (id)sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[PMCTool alloc] init];
    }
    return _sharedInstance;
}

- (NSArray *)getScenes {
    DBProcessTask *task = [[DBProcessTask alloc] init];
    task.sql = @"select scene_name,scene_id from scene_mstr order by scene_id";
    task.taskType = TaskQueryData;
    [[DBHelper sharedInstance] doTask:task];
    if (task.resultCode == 1) {
        return task.resultCollection;
    }
    return nil;
}

@end
