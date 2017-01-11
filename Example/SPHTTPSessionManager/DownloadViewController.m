//
//  Download_2_Controller.m
//  大文件断点下载
//
//  Created by lanou on 17/1/8.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "DownloadViewController.h"
#import "SPHTTPSessionManager.h"

// 所要下载的文件URL
#define SPFileURL @"http://120.25.226.186:32812/resources/videos/minion_01.mp4"

#define NetworkManager [SPHTTPSessionManager shareInstance]

@interface DownloadViewController ()
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

// 是否为蜂窝网络
@property (nonatomic, assign,getter=isReachableViaWWAN) BOOL reachableViaWWAN;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressView.progress = NetworkManager.storedDownloadProgress;
    
    if (NetworkManager.isDownloadCompleted) {
        [self.downloadButton setTitle:@"下载完成" forState:UIControlStateNormal];
        self.downloadButton.enabled = NO;
    }
    
    // 下载
    [self download];
    
    // 监测网络
    [self monitoringNetwork];
}


/** 下载 */
- (IBAction)downloadAction:(UIButton *)sender {
    if (!sender.selected) {
        
        if (self.isReachableViaWWAN) {
            
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"您现在使用的是蜂窝移动网络，确定要下载吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [sender setTitle:@"暂停" forState:UIControlStateNormal];
                // 启动任务
                [NetworkManager resumeTask];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"算了吧" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVc addAction:sureAction];
            [alertVc addAction:cancelAction];
            [self presentViewController:alertVc animated:YES completion:nil];
            
        } else {
            [sender setTitle:@"暂停" forState:UIControlStateNormal];
            // 启动任务
            [NetworkManager resumeTask];
        }

    } else {
        [sender setTitle:@"开始下载" forState:UIControlStateNormal];
        [NetworkManager suspendTask];
    }
    
    sender.selected = !sender.selected;
}

/** 删除 */
- (IBAction)removeAction:(UIButton *)sender {
    
    NSError *error = nil;
    
    BOOL removeSuccess = [NetworkManager removeDownloadedData:&error];
    
    if (removeSuccess) {
        [self.downloadButton setTitle:@"重新下载" forState:UIControlStateNormal];
        self.downloadButton.enabled = YES;
        self.downloadButton.selected = NO;
        self.progressView.progress = 0;
    }
}

- (void)download {
    // 选择下载方式
    NetworkManager.downloadway = SPDownloadWayRestart;
    
     [NetworkManager downloadWithURL:SPFileURL progress:^(CGFloat progress) {
        NSLog(@"progress:%f",progress);
        // 下载进度,在主线程中更新UI
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.progressView.progress = progress;
        });
        
    } complete:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        // 如若要更新UI,需要回到主线程
        
        // 获取文件路径
        NSString *path = filePath.path;
        NSLog(@"+++=%@",path);
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.downloadButton setTitle:@"下载完成" forState:UIControlStateNormal];
                self.downloadButton.enabled = NO;
            });
            NSLog(@"下载完成");
        } else {
            NSLog(@"error:%@",error);
            NSLog(@"下载失败");
            
            [self.downloadButton setTitle:@"下载失败，继续下载" forState:UIControlStateNormal];
        }
    }];
}

- (void)monitoringNetwork {
    [NetworkManager setReachabilityStatusChangeHandle:^(SPNetworkReachabilityState state) {
        
        switch (state) {
            case SPNetworkReachabilityStateUnknown: // 未知网络
                self.reachableViaWWAN = NO;
                break;
            case SPNetworkReachabilityStateNotReachabl:  // 没有网络
                self.reachableViaWWAN = NO;
                break;
            case SPNetworkReachabilityStateReachableViaWWAN:  // 蜂窝网络
                self.reachableViaWWAN = YES;
                break;
            case SPNetworkReachabilityStateReachableViaWiFi: // wifi
                self.reachableViaWWAN = NO;
                break;
                
            default:
                break;
        }
    }];
    // 开始监测
    [NetworkManager startMonitoring];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    // 停止网络监测
    [NetworkManager stopMonitoring];
}

@end
