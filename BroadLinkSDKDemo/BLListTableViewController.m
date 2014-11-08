//
//  BLListTableViewController.m
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLListTableViewController.h"
#import "BLNetwork.h"
#import "BLDeviceInfo.h"
#import "JSONKit.h"
#import "BLEasyConfigViewController.h"
#import "BLSP2ViewController.h"
#import "BLRM2ViewController.h"
#import "ViewController.h"
#import "MJExtension.h"
@interface BLListTableViewController ()
{
    dispatch_queue_t networkQueue;
}

@property (nonatomic, strong) BLNetwork *network;
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation BLListTableViewController

//-(NSMutableArray *)deviceArray
//{
//    if(_deviceArray==nil)
//    {
//        _deviceArray = [[NSMutableArray alloc] init];
//    }
//    
//    return  _deviceArray;
//}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    NSDate *date=[NSDate date];
    [self.navigationItem setTitle:[dateFormat stringFromDate:date]];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /*Init network queue.*/
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    
    /*Init network library*/
    _network = [[BLNetwork alloc] init];
    //_deviceArray = [[NSMutableArray alloc]init];
    _deviceArray = [self readDeviceInfoFromPlist];
    
    
    
    NSLog(@"viewDidLoad _deviceArray %@",_deviceArray);
    //[_deviceArray addObjectsFromArray:[self readDeviceInfoFromPlist]];
    
//    NSFileManager *fileMg=[NSFileManager defaultManager];
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *path = [doc stringByAppendingPathComponent:@"DeviceInfo.plist"];
//    [fileMg removeItemAtPath:path error:nil];
    
    /*Add device list refresh button.*/
    
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(listRefresh:)];
    UIBarButtonItem *tcpSocketItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(tcpSocketBarButtonItemClicked:)];
    NSArray *itemArray=[[NSArray alloc]initWithObjects:refreshButtonItem,tcpSocketItem, nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    
    /*Add easyConfig button*/
    UIBarButtonItem *easyConfigButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"EasyConfig" style:UIBarButtonItemStylePlain target:self action:@selector(easyConfigBarButtonItemClicked:)];
//    [easyConfigButtonItem setTintColor:[UIColor colorWithRed:132.0f/255.0f green:174.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    [self.navigationItem setLeftBarButtonItem:easyConfigButtonItem];
    
    [self setClearsSelectionOnViewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self networkInit];
    [self listRefresh:nil];
//    for (BLDeviceInfo *info in _deviceArray) {
//        [self deviceAdd:info];
//        NSLog(@"info.name %@",info.name);
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }    
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:info.name];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@", info.mac, info.type]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
        dispatch_async(networkQueue, ^{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:14] forKey:@"api_id"];
            [dic setObject:@"device_delete" forKey:@"command"];
            [dic setObject:info.mac forKey:@"mac"];
            
            NSData *requestData = [dic JSONData];
            
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            /*If parse success...*/
            if ([[responseData objectFromJSONData] objectForKey:@"code"] == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_deviceArray removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadData];
                });
            }
        });
    } 
    else if (editingStyle == UITableViewCellEditingStyleInsert) 
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
    if (![info.type isEqualToString:@"SP2"] && ![info.type isEqualToString:@"RM2"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This Demo only control SP2/RM2." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([info.type isEqualToString:@"SP2"])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:71] forKey:@"api_id"];
        [dic setObject:@"sp2_refresh" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        NSData *requestData = [dic JSONData];
        NSLog(@"MAC: %@", dic);
        dispatch_async(networkQueue, ^{
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
            {
                NSLog(@"success sp2");
                int state = [[[responseData objectFromJSONData] objectForKey:@"status"] intValue];
                [self enterSP2ViewController:info status:state];
            }
            else
            {
                NSLog(@"Error");
                //TODO:
            }
        });
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:131] forKey:@"api_id"];
        [dic setObject:@"rm2_refresh" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        NSData *requestData = [dic JSONData];
        
        dispatch_async(networkQueue, ^{
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
            {
                [self enterRM2ViewController:info];
                NSLog(@"success rm2");
            }
            else
            {
                NSLog(@"Error");
                //TODO:
            }
        });
    }
}

- (void)enterSP2ViewController:(BLDeviceInfo *)info status:(int)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BLSP2ViewController *viewController = [[BLSP2ViewController alloc] init];
        [viewController setInfo:info];
        [viewController setStatus:status];
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

- (void)enterRM2ViewController:(BLDeviceInfo *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BLRM2ViewController *viewController = [[BLRM2ViewController alloc] init];
        [viewController setInfo:info];
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

/*easyConfig action*/
- (void)easyConfigBarButtonItemClicked:(UIBarButtonItem *)item
{
    BLEasyConfigViewController *vc = [[BLEasyConfigViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tcpSocketBarButtonItemClicked:(UIBarButtonItem *)item
{
    ViewController *vc=[[ViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)listRefresh:(UIBarButtonItem *)item
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:11] forKey:@"api_id"];
    [dic setObject:@"probe_list" forKey:@"command"];

    NSData *requestData = [dic JSONData];
    dispatch_async(networkQueue, ^{
        /*Array must be save to database by your self, if no data change, probe_list can not response again.*/
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_deviceArray];
        
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"-------%d",[[[responseData objectFromJSONData] objectForKey:@"code"] intValue]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            
            
            
            NSArray *list = [[responseData objectFromJSONData] objectForKey:@"list"];
            for (NSDictionary *item in list)
            {
                int i;
                BLDeviceInfo *info = [[BLDeviceInfo alloc] init];
                [info setMac:[item objectForKey:@"mac"]];
                [info setType:[item objectForKey:@"type"]];
                [info setName:[item objectForKey:@"name"]];
                [info setLock:[[item objectForKey:@"lock"] intValue]];
                [info setPassword:[[item objectForKey:@"password"] unsignedIntValue]];
                [info setId:[[item objectForKey:@"id"] intValue]];
                [info setSubdevice:[[item objectForKey:@"subdevice"] intValue]];
                [info setKey:[item objectForKey:@"key"]];
                
                for (i=0; i<array.count; i++)
                {
                    BLDeviceInfo *tmp = [array objectAtIndex:i];
                    
                    if ([tmp.mac isEqualToString:info.mac])
                    {
                        [array replaceObjectAtIndex:i withObject:info];
                        break;
                    }
                }
                
                if (i >= array.count && ![info.type isEqualToString:@"Unknown"])
                {
                    [array addObject:info];
                    //[self deviceAdd:info];
                }
            }
            
            for (BLDeviceInfo *info in array) {
                [self deviceAdd:info];
                NSLog(@"info.name %@",info.name);
            }
            //NSLog(@"_deviceArray:%@",_deviceArray);
            [_deviceArray removeAllObjects];
            //NSLog(@"_deviceArray:%@",_deviceArray);
            [_deviceArray addObjectsFromArray:array];
            //_deviceArray = array;
            NSLog(@"list:%@",list);
            NSLog(@"array:%@",array);
            NSLog(@"_deviceArray:%@",_deviceArray);
            [self saveDeviceInfoToPlist];
            NSLog(@"硬件列表：%d",[_deviceArray count]);
            [self refreshDeviceList];
        }else{
            NSLog(@"probe_list error");
        }
    });
}

- (void)refreshDeviceList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)deviceAdd:(BLDeviceInfo *)info
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:[info keyValues]];
    //NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:12] forKey:@"api_id"];
    [dic setObject:@"device_add" forKey:@"command"];

    NSLog(@"%@", dic);
    NSData *requestData = [dic JSONData];
    
    dispatch_async(networkQueue, ^{
        NSData *responseData = [_network requestDispatch:requestData];
        
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSLog(@"Add %@ success!", info.mac);
        }
        else
        {
            NSLog(@"Add %@ failed!", info.mac);
            //TODO:
        }
    });
}

- (void)networkInit
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"api_id"];
    [dic setObject:@"network_init" forKey:@"command"];
#warning input your license.
    [dic setObject:@"U6mRbMpK5CLN5eikSIRuWuagtVKqWtjenPq/g/2Ttu2oOxJy8X4W2DW9uhsmcFyRZfgu3Y8bAoYR3BskKIH44p5BGQMZqg1X653Cg2jggev3yZ6Hag8=" forKey:@"license"];
    NSData *requestData = [dic JSONData];
    
//    dispatch_async(networkQueue, ^{
        NSData *responseData = [_network requestDispatch:requestData];
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSLog(@"Init success!");
        }
        else
        {
            NSLog(@"Init failed!");
            //TODO:
        }
//    });
}

-(void)saveDeviceInfoToPlist
{
    //获取应用程序根目录
    //NSString *home = NSHomeDirectory();
    // NSUserDomainMask 在用户目录下查找
    // YES 代表用户目录的~
    // NSDocumentDirectory 查找Documents文件夹
    // 建议使用如下方法动态获取
    //NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 拼接文件路径
    //NSString *path = [doc stringByAppendingPathComponent:@"DeviceInfo.plist"];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"DeviceInfo" ofType:@"plist"];
    NSLog(@"DeviceInfo.plist path : %@", path);
    
    
//    NSArray *array=[[NSArray alloc]initWithObjects:@"node1",@"node2", nil];
//    [array writeToFile:path atomically:YES];
    NSMutableArray *array = [self deviceInfoToDict];
//    [_deviceArray writeToFile:path atomically:YES];
    [array writeToFile:path atomically:YES];
    
        //读取数据
    //NSDictionary *dict1 = [NSDictionary dictionaryWithContentsOfFile:path];
   // NSLog(@"读取数据1  %@",[[NSMutableArray alloc] initWithContentsOfFile:path]);
}

-(NSMutableArray*)readDeviceInfoFromPlist{
    //NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //NSString *path = [doc stringByAppendingPathComponent:@"DeviceInfo.plist"];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"DeviceInfo" ofType:@"plist"];
    
    //读取数据
    //NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    //NSLog(@"读取数据  %@",dict);
    //return [dict objectForKey:@"DeviceInfo"];
    NSArray *list = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *array =[[NSMutableArray alloc]init];
    for (NSDictionary *item in list)
    {
        BLDeviceInfo *info = [[BLDeviceInfo alloc] init];
        [info setMac:[item objectForKey:@"mac"]];
        [info setType:[item objectForKey:@"type"]];
        [info setName:[item objectForKey:@"name"]];
        [info setLock:[[item objectForKey:@"lock"] intValue]];
        [info setPassword:[[item objectForKey:@"password"] unsignedIntValue]];
        [info setId:[[item objectForKey:@"id"] intValue]];
        [info setSubdevice:[[item objectForKey:@"subdevice"] intValue]];
        [info setKey:[item objectForKey:@"key"]];
        [array addObject:info];
        
    }

    NSLog(@"读取数据  %@",array);
    
    if (array != nil) {
        return  array;
    }else{
        return [[NSMutableArray alloc]init];
    }
}

-(NSMutableArray*)deviceInfoToDict{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSMutableDictionary *dic;
    for (BLDeviceInfo *info in _deviceArray) {
        dic = [[NSMutableDictionary alloc]init];
        [dic setObject:info.mac forKey:@"mac"];
        [dic setObject:info.type forKey:@"type"];
        [dic setObject:info.name forKey:@"name"];
        [dic setObject:[NSNumber numberWithInt:info.lock] forKey:@"lock"];
        [dic setObject:[NSNumber numberWithUnsignedInt:info.password] forKey:@"password"];
        [dic setObject:[NSNumber numberWithInt:info.id] forKey:@"id"];
        [dic setObject:[NSNumber numberWithInt:info.subdevice] forKey:@"subdevice"];
        [dic setObject:info.key forKey:@"key"];
        
        [array addObject:dic];
    }
    
    return array;
}
@end
