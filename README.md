# SPHTTPSessionManager
这个工具主要提供四大功能，get请求，post请求，断点下载和上传，断点下载是重点。本工具依赖AFN


下载功能说明：
下载时，先调用downloadWithURL: progress: complete:方法，

然后再用单例对象启动任务。[[SPHTTPSessionManager shareInstance] resumeTask]

当然也可以通过下载方法downloadWithURL: progress: complete:获取返回值task，然后再用task启动任务。之所以提供单例对象启动任务的方法，是为了让开发者彻底面向我这个单例对象。

暂停任务：
[[SPHTTPSessionManager shareInstance] suspendTask]；

取消任务
[[SPHTTPSessionManager shareInstance] cancelTask]；

对于下载有两种模式：这两种模式分别对应两个枚举值：SPDownloadWayResume和SPDownloadWayRestart，他们最大的区别是前者可以再杀死app然后重启app时继续上一次的下载，后者每次重启需要重新下载。默认是SPDownloadWayResume模式
