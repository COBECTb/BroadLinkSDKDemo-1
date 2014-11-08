//
//  BLSP2ViewController.m
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLSP2ViewController.h"
#import "BLNetwork.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyUserWords.h"
#import "RecognizerFactory.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "ISRDataHelper.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"

@interface BLSP2ViewController ()
{
    dispatch_queue_t networkQueue;
}

@property (nonatomic, strong) BLNetwork *network;

@end

@implementation BLSP2ViewController
@synthesize voiceImageView;
@synthesize voiceImageLightView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    //创建语音识别对象
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:_info.name];
    
    networkQueue = dispatch_queue_create("BroadLinkSP2NetworkQueue", DISPATCH_QUEUE_SERIAL);
    _network = [[BLNetwork alloc] init];
    
    //手动开关
    UILabel *manualLabel=[[UILabel alloc]init];
    [manualLabel setText:@"手动开关"];
    manualLabel.frame=CGRectMake(0, 0, 100, 20);
    [self.view addSubview:manualLabel];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(110, 40, 100.0f, 100.0f)];
    [_button.layer setCornerRadius:50.0f];
    [_button.layer setMasksToBounds:YES];
    [_button setSelected:_status];
    [_button setTitle:(_status) ? @"on" : @"off" forState:UIControlStateNormal];
    if (_status)
        [_button setBackgroundColor:[UIColor greenColor]];
    else
        [_button setBackgroundColor:[UIColor redColor]];
    [_button addTarget:self action:@selector(stateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //语音开关
    UILabel *voiceLabel=[[UILabel alloc]init];
    [voiceLabel setText:@"语音开关"];
    voiceLabel.frame=CGRectMake(0, 170, 100, 20);
    [self.view addSubview:voiceLabel];
    
    voiceImageLightView=[[UIImageView alloc]initWithFrame:CGRectMake(92, 202,136, 136)];
    voiceImageLightView.contentMode=UIViewContentModeScaleToFill;
    voiceImageLightView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:voiceImageLightView];
    
    voiceImageView=[[UIImageView alloc]initWithFrame:CGRectMake(110, 220,100, 100)];
    voiceImageView.contentMode=UIViewContentModeScaleToFill;
    voiceImageView.image=[UIImage imageNamed:@"voiceImg.jpg"];
    [self.view addSubview:voiceImageView];
    
    
    
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    voiceButton.frame = CGRectMake(110, 220,100, 100);
//    [voiceButton setBackgroundImage:[UIImage imageNamed:@"voiceImg.jpg"] forState:UIControlStateNormal];
    voiceButton.backgroundColor=[UIColor clearColor];

    
    
    [voiceButton addTarget:self action:@selector(voiceButtontouchDown:) forControlEvents:UIControlEventTouchDown];
    [voiceButton addTarget:self action:@selector(voiceButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    [self.view addSubview:voiceButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)stateButtonClicked:(UIButton *)button
{
    int status = !button.isSelected;
    
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:72] forKey:@"api_id"];
        [dic setObject:@"sp2_control" forKey:@"command"];
        [dic setObject:_info.mac forKey:@"mac"];
        [dic setObject:[NSNumber numberWithInt:status] forKey:@"status"];

        NSData *requestData = [dic JSONData];
        
        NSData *responseData = [_network requestDispatch:requestData];
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setSelected:status];
                [button setTitle:(status) ? @"on" : @"off" forState:UIControlStateNormal];
                if (status){
                    [button setBackgroundColor:[UIColor greenColor]];
                    _status = status;
                }else{
                    [button setBackgroundColor:[UIColor redColor]];
                    _status = status;
                }
                
            });
        }
        else if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == -106)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your operation is too fast" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }
        else
        {
            NSLog(@"Set status failed!");
            //TODO;
        }
    });
}

- (void)voiceButtontouchDown:(UIButton *)button
{
    //修改VoiceButton背景图片，有光晕
    voiceImageLightView.image=[UIImage imageNamed:@"voiceImgLight.jpg"];
    voiceImageView.image=nil;
    voiceImageView.backgroundColor=[UIColor clearColor];
    
    NSLog(@"Button touch down");
    self.text =nil;
    //设置为录音模式
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //开始录音识别
    bool ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        //[_voiceButton setEnabled:NO];
        
    }
    else
    {
        NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
    }
    
}

- (void)voiceButtonTouchUpInside:(UIButton *)button
{
    //修改VoiceButton背景图片，无光晕
    voiceImageView.image=[UIImage imageNamed:@"voiceImg.jpg"];
    voiceImageLightView.image=nil;
    voiceImageLightView.backgroundColor=[UIColor clearColor];
    
    //停止录音识别
     NSLog(@"Button touch up inside");
    [_iFlySpeechRecognizer stopListening];
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调，当录音的声音的大小发生变化时调用
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
    
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    NSLog(@"%@",vol);
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech
{
    NSLog(@"正在录音");
    
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{
    NSLog(@"停止录音");
}


/**
 * @fn      onResults
 * @brief   识别结果回调，对录音的结果进行识别回调，转化成文字
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    //NSLog(@"听写结果：%@",resultString);
    
    self.result =[NSString stringWithFormat:@"%@%@", self.text,resultString];
    
    NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:resultString];
    NSLog(@"听写结果(json)：%@",  resultFromJson);
    self.text = [NSString stringWithFormat:@"%@%@", self.text,resultFromJson];
    
    if (isLast)
    {
        NSLog(@"听写结果(json)：%@测试",  self.text);
    }
    
    NSLog(@"isLast=%d",isLast);
}

/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    NSString *text ;
    int status = 2;
    if (error.errorCode ==0 ) {
        
        if (_result.length==0) {
            
            text = @"无识别结果";
        }
        else
        {
            text = @"识别成功";
            NSRange range1 = [self.text rangeOfString:@"插座开"];
            NSRange range2 = [self.text rangeOfString:@"插座关"];
            if (range1.length>0) {
                status = 1;
                NSLog(@"插座开，status=1");
            } else if(range2.length>0){
                status = 0;
                NSLog(@"插座关，status=2");
            }
            if (status!=2 && status!=_status) {
                
                dispatch_async(networkQueue, ^{
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:[NSNumber numberWithInt:72] forKey:@"api_id"];
                    [dic setObject:@"sp2_control" forKey:@"command"];
                    [dic setObject:_info.mac forKey:@"mac"];
                    [dic setObject:[NSNumber numberWithInt:status] forKey:@"status"];
                    
                    NSData *requestData = [dic JSONData];
                    
                    NSData *responseData = [_network requestDispatch:requestData];
                    if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                           
                            if (status){
                                _status = status;
                                [_button setTitle:@"on" forState:UIControlStateNormal];
                                [_button setBackgroundColor:[UIColor greenColor]];
                            }else{
                                _status = status;
                                [_button setTitle:@"off" forState:UIControlStateNormal];
                                [_button setBackgroundColor:[UIColor redColor]];
                            }
                            
                        });
                    }
                    else if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == -106)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your operation is too fast" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alertView show];
                        });
                    }
                    else
                    {
                        NSLog(@"Set status failed!");
                        //TODO;
                    }
                });

            }
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        
    }
    //[_voiceButton setEnabled:YES];
    NSLog(@"回调结束：：%@",text);
    
}


@end
