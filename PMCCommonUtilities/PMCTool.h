//
//  PMCTool.h
//  PMCCommonUtilities
//
//  Created by wangbo on 13-8-14.
//  Copyright (c) 2013年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMCTool : NSObject

@property (nonatomic, strong)NSString *officeId;

+ (id)sharedInstance;

//control light
- (void)changeLightDimming:(int)dimming ForIP:(NSString *)ip;

- (void)changeAllLightDimming:(int)dimming;

- (void)changeToScene:(int)sceneId;

- (void)switchAllLight:(BOOL)isOn;

- (NSDictionary *)getLightStatusWithIP:(NSString *)ip;

//relate to database
- (int)getSceneCountInOffice;
- (NSArray *)getScenes;
- (NSArray *)getLightsForScene:(int)sceneId;
- (NSArray *)getLightsInOffice;

- (void)updateLightsForScene:(int)sceneId withData:(NSArray *)array withSceneName:(NSString *)sceneName;

- (BOOL)replaceLightsInfo:(NSArray *)array;

- (BOOL)registerScenesWithServerData:(NSArray *)array;


@end
