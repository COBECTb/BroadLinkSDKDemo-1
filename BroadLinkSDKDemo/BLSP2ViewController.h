//
//  BLSP2ViewController.h
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLDeviceInfo.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

@interface BLSP2ViewController : UIViewController<IFlySpeechRecognizerDelegate,UIActionSheetDelegate>


//识别对象
@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic, strong) BLDeviceInfo *info;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString             * result;
@property (nonatomic, strong) NSString             * text;
@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong) UIImageView *voiceImageView;
@property (nonatomic,strong) UIImageView *voiceImageLightView;
@end
