//
//  ViewController.m
//  zxSocket
//
//  Created by 张 玺 on 12-3-24.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import "ViewController.h"
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

@interface ViewController ()
{
//    dispatch_queue_t networkQueue1;
}
@end

@implementation ViewController
@synthesize socket;
@synthesize host;
@synthesize port;
@synthesize button;
@synthesize voiceImageView;
@synthesize voiceImageLightView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    //创建语音识别对象
    _iFlySpeechRecognizer1 = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)addText:(NSString *)str
{
//    status.text = [status.text stringByAppendingFormat:@"%@\n",str];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"TCPConnect"];

    UILabel *hostLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 50, 20)];
    hostLabel.text=@"Host:";
    [self.view addSubview:hostLabel];
    
    host=[[UITextField alloc]initWithFrame:CGRectMake(50, 10, 150, 20)];
    [host setBorderStyle:UITextBorderStyleRoundedRect];
    
    UILabel *portLabel=[[UILabel alloc]initWithFrame:CGRectMake(200, 10, 50, 20)];
    portLabel.text=@"Port:";
    [self.view addSubview:portLabel];
    
    port=[[UITextField alloc]initWithFrame:CGRectMake(250, 10, 70, 20)];
    [port setBorderStyle:UITextBorderStyleRoundedRect];
    
    button=[UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake(100, 50, 100, 20);
    host.text = @"192.168.0.150";
    port.text = @"8899";
    
    [button setTitle:@"连接" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(connectButtontouchDown:) forControlEvents:UIControlEventTouchDown];

    [self.view addSubview:host];
    [self.view addSubview:port];
    [self.view addSubview:button];
    
    voiceImageLightView=[[UIImageView alloc]initWithFrame:CGRectMake(92, 152,136, 136)];
    voiceImageLightView.contentMode=UIViewContentModeScaleToFill;
    voiceImageLightView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:voiceImageLightView];
    
    voiceImageView=[[UIImageView alloc]initWithFrame:CGRectMake(110, 170,100, 100)];
    voiceImageView.contentMode=UIViewContentModeScaleToFill;
    voiceImageView.image=[UIImage imageNamed:@"voiceImg.jpg"];
    [self.view addSubview:voiceImageView];
    
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    voiceButton.frame = CGRectMake(110, 170,100, 100);
    voiceButton.backgroundColor=[UIColor clearColor];
    
    [voiceButton addTarget:self action:@selector(voiceButtontouchDown:) forControlEvents:UIControlEventTouchDown];
    [voiceButton addTarget:self action:@selector(voiceButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceButton];

	// Do any additional setup after loading the view, typically from a nib.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)viewDidUnload
{
    [self setHost:nil];
    [self setPort:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)connectButtontouchDown:(UIButton *)button
{
    socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if(![socket connectToHost:host.text onPort:[port.text intValue] error:&err])
    {
        [self addText:err.description];
    }else
    {
        NSLog(@"ok");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"连接成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        //        [self addText:@"打开端口"];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //[self addText:[NSString stringWithFormat:@"连接到:%@",host]];
    [socket readDataWithTimeout:-1 tag:0];
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSString *newMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    [self addText:[NSString stringWithFormat:@"%@:%@",sock.connectedHost,newMessage]];
    [socket readDataWithTimeout:-1 tag:0];
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
    [_iFlySpeechRecognizer1 setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //开始录音识别
    bool ret = [_iFlySpeechRecognizer1 startListening];
    
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
    [_iFlySpeechRecognizer1 stopListening];
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
            NSRange range1 = [self.text rangeOfString:@"开灯"];
            NSRange range2 = [self.text rangeOfString:@"关灯"];
            if (range1.length>0) {
                status = 1;
                NSLog(@"开灯，status=1");
            } else if(range2.length>0){
                status = 0;
                NSLog(@"关灯，status=2");
            }
            if(status==1)
            {
                [socket writeData:[@"GPIO 11 OUT 1" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                [socket readDataWithTimeout:-1 tag:0];
            }
            else if(status==0)
            {
                [socket writeData:[@"GPIO 11 OUT 0" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
                [socket readDataWithTimeout:-1 tag:0];
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
