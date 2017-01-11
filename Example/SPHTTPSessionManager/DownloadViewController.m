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

#define Manager [SPHTTPSessionManager shareInstance]

@interface DownloadViewController ()
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"-----%f",Manager.storedDownloadProgress);
    
    self.progressView.progress = Manager.storedDownloadProgress;
    
    if (Manager.isDownloadCompleted) {
        [self.downloadButton setTitle:@"下载完成" forState:UIControlStateNormal];
        self.downloadButton.enabled = NO;
    }
    
    // 下载
    [self download];
    
    
}


/** 下载 */
- (IBAction)downloadAction:(UIButton *)sender {
    if (!sender.selected) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        
        // 启动任务
        [Manager resumeTask];
        
    } else {
        [sender setTitle:@"开始下载" forState:UIControlStateNormal];
        [Manager suspendTask];
    }
    
    sender.selected = !sender.selected;
}

/** 删除 */
- (IBAction)removeAction:(UIButton *)sender {
    
    NSError *error = nil;
    
    BOOL removeSuccess = [Manager removeDownloadedData:&error];
    
    if (removeSuccess) {
        [self.downloadButton setTitle:@"重新下载" forState:UIControlStateNormal];
        self.downloadButton.enabled = YES;
        self.downloadButton.selected = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.progress = 0;
        });

    }
}

- (void)download {
    // 选择下载方式
    Manager.downloadway = SPDownloadWayResume;
    [Manager downloadWithURL:SPFileURL progress:^(CGFloat progress) {
        //NSLog(@"progress:%f",progress);
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
            //NSLog(@"error:%@",error);
            NSLog(@"下载失败");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
