//
//  NetworkManager.h
//  NetworkManager
//
//  Created by leshengping on 16/9/8.
//  Copyright © 2016年 idress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SPDownloadWay) {
    SPDownloadWayResume,    // 这种下载方式支持重启app时继续上一次的下载
    SPDownloadWayRestart    // 这种下载方式不支持重启app时继续上一次的下载
    
    // SPDownloadWayResume和SPDownloadWayRestart的下载方式具体异同点如下：
    /*
    1、SPDownloadWayResume和SPDownloadWayRestart均支持断点下载
    2、SPDownloadWayResume支持重启app继续上一次下载,SPDownloadWayRestart不支持
    3、SPDownloadWayResume会自动判断是否下载完成，并保存每时每刻下载的进度值，SPDownloadWayRestart没有此功能
    4、SPDownloadWayResume支持任何时刻删除已经下载的文件数据，SPDownloadWayRestart不支持在下载过程中删除，只有下载完成时才能删除
    5、SPDownloadWayResume不依赖于AFN，SPDownloadWayRestart依赖AFN
     
     通俗的讲，SPDownloadWayResume和SPDownloadWayRestart的根本区别就是前者是沙盒模式，后者是内存模式
     */
    
};

typedef NS_ENUM(NSInteger, SPNetworkReachabilityState){
    SPNetworkReachabilityStateUnknown = -1,             // 未知网络
    SPNetworkReachabilityStateNotReachabl = 0,          // 没有网络
    SPNetworkReachabilityStateReachableViaWWAN = 1,     // 蜂窝网络
    SPNetworkReachabilityStateReachableViaWiFi = 2      // WiFi
};

NS_ASSUME_NONNULL_BEGIN
@interface SPHTTPSessionManager : NSObject

/** 单例对象 */
+ (instancetype)shareInstance;


/*****************************  get、post相关  ***************************/

/**
 *  get请求
 *
 *  @param urlString 请求地址
 *  @param params    参数字典
 *  @param success   请求成功回调的block
 *  @param failure   请求失败回调的block
 */
- (void)GET:(NSString *)urlString
     params:(nullable NSDictionary *)params
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure;

/**
 *  post请求
 *
 *  @param urlString 请求地址
 *  @param params    参数字典
 *  @param success   请求成功回调的block
 *  @param failure   请求失败回调的block
 */
- (void)POST:(NSString *)urlString
      params:(nonnull NSDictionary *)params
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

/** 请求超时时间间隔,默认30s */
@property (nonatomic, assign) double requestTimeoutInterval;


/*****************************  下载相关  *******************************/

/**
 *  下载
 *
 *  @param urlString 请求地址
 *  @param downloadProgressBlock  下载过程中回调的block
 *  @complete 下载完成回调的block
 */
- (NSURLSessionTask *)downloadWithURL:(NSString *)urlString
                                     progress:(void (^)(CGFloat progress))downloadProgressBlock
                                     complete:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/** 下载方式 */
@property (nonatomic, assign) SPDownloadWay downloadway;

/*
 *  启动任务
 *
 */
- (void)resumeTask;
/*
 *  暂停任务
 *
 */
- (void)suspendTask;
/*
 *  取消任务
 *
 */
- (void)cancelTask;

/*
 *  移除已经下载好的文件数据
 *
 */
- (BOOL)removeDownloadedData:(NSError * _Nullable __autoreleasing * _Nullable)error;

/** 是否正在下载,对于SPDownloadResume下载方式，该属性来源于沙盒，对于SPDownloadRestart下载方式，该属性来源于内存 */
@property (nonatomic, assign, readonly, getter=isDownloading) BOOL downloading;


// 以下两个属性只对SPDownloadResume下载方式奏效

/** 保存在沙盒中的进度值 */
@property (nonatomic, assign, readonly) CGFloat storedDownloadProgress;
/** 是否已经下载完毕 */
@property (nonatomic, assign, readonly, getter=isDownloadCompleted) BOOL downloadCompleted;


/*****************************  上传相关  *******************************/

/*
 * 上传  http://www.cnblogs.com/qingche/p/5489434.html
 *
 */
- (void)uploadWithURL:(NSString *)urlString
               params:(NSDictionary *)params
             fileData:(NSData *)filedata
                 name:(NSString *)name
             fileName:(NSString *)filename
             mimeType:(NSString *) mimeType
             progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
              success:(void (^)(id responseObject))success
              failure:(void (^)(NSError *error))failure;



/*****************************  网络监测相关  *******************************/

/** 
 *  监测网络
 *  @param handel 监测到网络或网络发生改变时回调的block
 *
 */
- (void)setReachabilityStatusChangeHandle:(void (^)(SPNetworkReachabilityState state))handel;
/**
 *  开始检测
 *
 */
- (void)startMonitoring;
/**
 *  停止检测
 *
 */
- (void)stopMonitoring;

@end
NS_ASSUME_NONNULL_END


@interface NSString (MD5)

@property (nullable, nonatomic, readonly) NSString *md5String;

@end








