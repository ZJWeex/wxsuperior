//
//  NSURL+XZOL.m
//  Knowledge
//
//  Created by Dao on 2018/7/17.
//  Copyright © 2018 XueZhiOnline. All rights reserved.
//

#import "NSURL+XZOL.h"


@implementation NSURL (XZOL)

+ (NSURL *)weexUrlWithFilePath:(NSString *)filePath{

    NSString *fullpath = nil;
#if DEBUG
//    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
//    NSString *basePath = [NSString stringWithFormat:@"%@/dist/base-superior/",mainBundlePath];
//    fullpath = [NSString stringWithFormat:@"%@%@", basePath, filePath];
//    return [NSURL fileURLWithPath:fullpath isDirectory:YES];
#endif
    fullpath = [NSString stringWithFormat:@"%@%@", self.HTTP_RemoteResourceReplace, filePath];
    return [NSURL URLWithString:fullpath];

}

#pragma mark -- thybridURL
+ (NSString *)TCM_RemoteService{
    //设置网络环境
#if DEBUG
    return @"http://dev.taocaimall.com/taocaimall";
#else
    return @"http://app.taocaimall.com/taocaimall";
#endif
}

+ (NSString *)HTTP_RemoteResourceBase{
#if DEBUG
    //本地服务器
    return  @"http://192.168.15.220:8081/dist/";
#else
    //设置远程服务器
    return  @"http://192.168.15.220:8081/dist/";
    
#endif
}
+ (NSString *)HTTP_RemoteResourceReplace{
#if DEBUG
    //本地服务器
    return  @"http://192.168.15.220:8081/dist/";
#else
    //设置远程服务器
    return  @"http://192.168.15.220:8081/dist/";
    
#endif
    
}
+ (NSString *)HTTPS_RemoteResourceBase{
#if DEBUG
    //本地服务器
    return  @"http://192.168.15.220:8081/dist/";
#else
    //设置远程服务器
    return  @"http://192.168.15.220:8081/dist/";
    
#endif
}
+ (NSString *)HTTPS_RemoteResourceReplace{
#if DEBUG
    //本地服务器
    return  @"http://192.168.15.220:8081/dist/";
#else
    //设置远程服务器
    return  @"http://192.168.15.220:8081/dist/";
    
#endif
}
@end
