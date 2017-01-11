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
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelerationLabel;

@property (nonatomic, strong) NSTimer *timer;

// 保存已经下载完成的数据大小
@property (nonatomic, assign) CGFloat completedLength;
// 保存1秒前下载完成的数据大小
@property (nonatomic, assign) CGFloat lastCompletedLength;
// 保存1秒前的速度值
@property (nonatomic, assign) CGFloat lastSpeed;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressView.transform = CGAffineTransformMakeScale(1.0, 5.0);
    
    self.progressView.progress = NetworkManager.storedDownloadProgress;
    
    if (NetworkManager.isDownloadCompleted) {
        [self.downloadButton setTitle:@"下载完成" forState:UIControlStateNormal];
        self.downloadButton.enabled = NO;
    }
    
    // 下载
    [self download];
    
}


/** 下载 */
- (IBAction)downloadAction:(UIButton *)sender {
    
    
    
    if (!sender.selected) {
        // 监测网络
        [self monitoringNetwork];

    } else {
        
        [NetworkManager suspendTask];
        [self.downloadButton setTitle:@"开始下载" forState:UIControlStateNormal];
    }
    
    sender.selected = !sender.selected;
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showSpeedAndAcceleration) userInfo:nil repeats:YES];
    
}

// 显示速度和加速度
- (void)showSpeedAndAcceleration {
    // 速度等于1秒间隔内两数据之差
    CGFloat speed = (self.completedLength - self.lastCompletedLength)/1000;
    self.speedLabel.text = [NSString stringWithFormat:@"%.0fK/S",speed]; // 除以1000是为了精确到百位
    // 加速度等于1秒间隔内两速度之差(不考虑正负，故取绝对值)
    CGFloat acceleration = fabs(speed - self.lastSpeed);
    self.accelerationLabel.text = [NSString stringWithFormat:@"+%.0f",acceleration];
    self.lastCompletedLength = self.completedLength;
    self.lastSpeed = speed;
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
    NetworkManager.downloadway = SPDownloadWayResume;
    
     [NetworkManager downloadWithURL:SPFileURL progress:^(NSProgress *progress) {
        NSLog(@"progress:%lld",progress.completedUnitCount);
        // 下载进度,在主线程中更新UI
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.progressView.progress = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
            self.promptLabel.text = [NSString stringWithFormat:@"%.1fM/%.1fM",progress.completedUnitCount / (1000.0 * 1000.0),progress.totalUnitCount / (1000.0*1000.0)];
        });
         
         self.completedLength = progress.completedUnitCount;
        
    } complete:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        // 如若要更新UI,需要回到主线程
        
        // 获取文件路径
        NSString *path = filePath.path;
        NSLog(@"+++=%@",path);
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.downloadButton setTitle:@"下载完成" forState:UIControlStateNormal];
                self.downloadButton.enabled = NO;
                
                [self.timer invalidate];
                self.timer = nil;
                self.promptLabel.text = @"";
                self.accelerationLabel.text = @"";
                self.speedLabel.text = @"";
            });
            NSLog(@"下载完成");
        } else {
            //NSLog(@"error:%@",error);
            //NSLog(@"下载失败");

            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == -1005 ) {
                NSLog(@"网络断开了");
               
            }
            
            
        }
    }];
}

- (void)monitoringNetwork {
    [NetworkManager setReachabilityStatusChangeHandle:^(SPNetworkReachabilityState state) {
        
        switch (state) {
            case SPNetworkReachabilityStateUnknown: // 未知网络
                [self.downloadButton setTitle:@"暂停" forState:UIControlStateNormal];
                [NetworkManager resumeTask];
                break;
            case SPNetworkReachabilityStateNotReachabl:  // 没有网络
                [self.downloadButton setTitle:@"开始下载" forState:UIControlStateNormal];
                 self.promptLabel.text = @"网络断开了亲，请检查您的网络";
                break;
            case SPNetworkReachabilityStateReachableViaWWAN:  // 蜂窝网络
                // 蜂窝网络下是否继续下载
                [self prompt3G4G_network];
                break;
            case SPNetworkReachabilityStateReachableViaWiFi: // wifi
                [self.downloadButton setTitle:@"暂停" forState:UIControlStateNormal];
                [NetworkManager resumeTask];
                break;
                
            default:
                break;
        }
    }];
    // 开始监测
    [NetworkManager startMonitoring];
}

- (void)prompt3G4G_network {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"您现在使用的是蜂窝移动网络，这可能会耗费您的流量，确定要下载吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.downloadButton setTitle:@"暂停" forState:UIControlStateNormal];
        // 启动任务
        [NetworkManager resumeTask];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"算了吧" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.downloadButton setTitle:@"开始下载" forState:UIControlStateNormal];
    }];
    [alertVc addAction:sureAction];
    [alertVc addAction:cancelAction];
    [self presentViewController:alertVc animated:YES completion:nil];
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
