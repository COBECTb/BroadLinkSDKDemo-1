//
//  NSObject+BLStudyModel.m
//  BroadLinkSDKDemo
//
//  Created by cisl on 14-10-27.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import "BLRM2StudyModel.h"
#import "JSONKit.h"

@interface BLRM2StudyModel ()
{
    
}

@property (nonatomic, strong) BLNetwork *network;

//@property (nonatomic, strong) NSString *data;

@end

@implementation BLRM2StudyModel

- (instancetype)initWithArgument :(BLDeviceInfo*)info
{
    if(self = [super init])
    {
        _network = [[BLNetwork alloc] init];
        _info = info;
    }
    return self;
}

+ (instancetype)studyModelWithArgument :(BLDeviceInfo*)info
{
    return [[self alloc] initWithArgument:info];
}

/*Study model start,rm2's red bulb light up*/
- (NSString *)rm2StudyModelStart
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:132] forKey:@"api_id"];
    [dic setObject:@"rm2_study" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    NSData *requestData = [dic JSONData];
    NSData *responseData = [_network requestDispatch:requestData];
    NSLog(@"%@", [responseData objectFromJSONData]);
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //    [alertView show];
    if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0) {
        return [[responseData objectFromJSONData] objectForKey:@"code"];
    } else {
        NSLog(@"rm2 enter study mode failed, fail code: %@",[[responseData objectFromJSONData] objectForKey:@"code"]);
        //[self performSelectorOnMainThread:@selector(enterStudyModeFailed) withObject:nil waitUntilDone:NO];
        return nil;
    }
}


/*get control data*/
- (NSString *)rm2GetControlData
{
    
    BOOL isGetData = NO;
    int times = 0;
    while (!isGetData && times< 10) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:133] forKey:@"api_id"];
        [dic setObject:@"rm2_code" forKey:@"command"];
        [dic setObject:_info.mac forKey:@"mac"];
        NSData *requestData = [dic JSONData];
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            isGetData = YES;
            NSString * data = [[responseData objectFromJSONData] objectForKey:@"data"];
            //NSLog(@"get code : %@",data);
            return data;
        }else{
            [NSThread sleepForTimeInterval:1.0];
            times++;
        }
        
    }
    return nil;
    
}

/*Send data command*/
- (NSString *)rm2SendControlData:(NSString *)data
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:134] forKey:@"api_id"];
    [dic setObject:@"rm2_send" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    [dic setObject:data forKey:@"data"];
    NSData *requestData = [dic JSONData];
    NSData *responseData = [_network requestDispatch:requestData];
    NSLog(@"%@", [responseData objectFromJSONData]);
    return [[responseData objectFromJSONData] objectForKey:@"code"];
}


@end
