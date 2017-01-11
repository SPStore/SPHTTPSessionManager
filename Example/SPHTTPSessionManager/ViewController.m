//
//  ViewController.m
//  大文件断点下载
//
//  Created by lanou on 17/1/5.
//  Copyright © 2017年 leshengping. All rights reserved.
//



#import "ViewController.h"
#import "SPHTTPSessionManager.h"
#import "DownloadViewController.h"

@interface ViewController () <NSURLSessionDataDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
}

// get请求
- (IBAction)get:(UIButton *)sender {
    
    // 请求地址
    NSString *urlString = @"http://www.baidu.com";
    // 请求参数,AFN的get请求会自动把字典参数拼接到url后面去
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"参数名"] = @"参数值";
    params[@"参数名"] = @"参数值";
    //...
    
    SPHTTPSessionManager *mgr = [SPHTTPSessionManager shareInstance];
    
    [mgr GET: urlString params:params success:^(id responseObject) {
        // 请求成功会来到这个block,在这里拿到接口数据(来到这里已经是主线程，不需要再次回到主线程）
        NSLog(@"请求成功,responseObject = %@",responseObject);
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];
}

- (IBAction)post:(UIButton *)sender {
    
    // 请求地址
    NSString *urlString = @"http://www.baidu.com";
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"参数名"] = @"参数值";
    params[@"参数名"] = @"参数值";
    //...
    
    SPHTTPSessionManager *mgr = [SPHTTPSessionManager shareInstance];
    
    [mgr POST: urlString params:params success:^(id responseObject) {
        // 请求成功会来到这个block,在这里拿到接口数据(来到这里已经是主线程，不需要再次回到主线程）
        NSLog(@"请求成功,responseObject = %@",responseObject);
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];
    
}

- (IBAction)download:(UIButton *)sender {
    DownloadViewController *download2Vc = [[DownloadViewController alloc] init];
    [self.navigationController pushViewController:download2Vc animated:YES];
}

@end
