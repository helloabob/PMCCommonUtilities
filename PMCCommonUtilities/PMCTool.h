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
- (void)changeAllLightDimming:(int)dimming;

- (void)changeToScene:(NSString *)sceneName;

- (void)switchAllLight:(BOOL)isOn;

//relate to database
- (NSArray *)getScenes;
- (NSArray *)getLightsForScene:(NSString *)sceneName;


@end
