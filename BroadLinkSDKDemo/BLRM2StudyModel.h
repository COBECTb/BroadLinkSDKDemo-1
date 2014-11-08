//
//  BLRM2StudyModel.h
//  BroadLinkSDKDemo
//
//  Created by cisl on 14-10-27.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLNetwork.h"
#import "BLDeviceInfo.h"

@interface BLRM2StudyModel : NSObject

@property (nonatomic, strong) BLDeviceInfo *info;

- (instancetype)initWithArgument :(BLDeviceInfo*)info;
+ (instancetype)studyModelWithArgument :(BLDeviceInfo*)info;

- (NSString *)rm2StudyModelStart;
- (NSString *)rm2GetControlData;
- (NSString *)rm2SendControlData:(NSString *)data;
@end
