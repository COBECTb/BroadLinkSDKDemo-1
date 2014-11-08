//
//  ViewController.h
//  zxSocket
//
//  Created by 张 玺 on 12-3-24.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

@interface ViewController : UIViewController<GCDAsyncSocketDelegate,IFlySpeechRecognizerDelegate,UIActionSheetDelegate>
{
    GCDAsyncSocket *socket;
}

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer1;
@property(strong)  GCDAsyncSocket *socket;

@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString             * result;
@property (nonatomic, strong) NSString             * text;

@property (strong, nonatomic) UITextField *host;
@property (strong, nonatomic) UITextField *port;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIImageView *voiceImageView;
@property (nonatomic,strong) UIImageView *voiceImageLightView;


@end
