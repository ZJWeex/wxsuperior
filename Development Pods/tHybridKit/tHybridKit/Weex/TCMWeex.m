//
//  TCMWeex.m
//  Weex
//
//  Created by Dao on 2018/1/9.
//  Copyright © 2018年 Taocaimall. All rights reserved.
//

#import "TCMWeex.h"

#import "WeexSDK.h"
#import "TCMWeexImageLoader.h"
#import "tHybridModulesLoader.h"
#import "thybridNavigationDefaultImpl.h"
#import "UIViewController+tHybridWeex.h"

@implementation tHybridKit
BOOL _Thybrid_Kit_Network_Working_ = NO;
BOOL _Thybrid_Kit_Iphone_X_ = NO;

+ (void)launchingWeex{

    [self initDeviceEnvironment];

    [WXLog setLogLevel:WXLogLevelLog];

    [WXAppConfiguration setAppGroup:@"Taocaimall"];
    [WXAppConfiguration setAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey]];

    [WXAppConfiguration setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];

    //初始化环境
    [WXSDKEngine initSDKEnvironment];

    //注册图片加载器
    [WXSDKEngine registerHandler:[TCMWeexImageLoader new] withProtocol:@protocol(WXImgLoaderProtocol)];
    [WXSDKEngine registerHandler:[thybridNavigationDefaultImpl new] withProtocol:@protocol(WXNavigationProtocol)];

    //注册Model
    [tHybridModulesLoader loadModels:^(__unsafe_unretained Class modelClass, NSString *modelName) {
        [WXSDKEngine registerModule:modelName withClass:modelClass];
    }];
}

+ (void)initDeviceEnvironment{
    CGRect frame = [UIScreen mainScreen].bounds;
    NSInteger Width = CGRectGetWidth(frame);
    NSInteger Height = CGRectGetHeight(frame);
    if ((Width == 375 && Height != 667) || (Width == 414 && Height != 736)) {
        _Thybrid_Kit_Iphone_X_ = YES;
    }
}


+ (void)launchingWeex:(NSString *)networkEnvironment{
    [self launchingWeex];
    //自定义网络环境变量
    if (networkEnvironment) {
        [WXSDKEngine setCustomEnvironment:@{@"netEnv":networkEnvironment}];
    }
}

+ (BOOL)Thybrid_Kit_Iphone_X{
    return _Thybrid_Kit_Iphone_X_;
}

+ (NSInteger)Thybrid_Kit_Network_Working{
    return _Thybrid_Kit_Network_Working_;
}
+ (void)setThybrid_Kit_Network_Working:(NSInteger)Thybrid_Kit_Network_Working{
    _Thybrid_Kit_Network_Working_ = Thybrid_Kit_Network_Working;
    if (!Thybrid_Kit_Network_Working) {
        return;
    }
    UIWindow *win = [UIApplication sharedApplication].delegate.window;
    UIViewController *rootViewCoontroller = win.rootViewController;
    if ([rootViewCoontroller isKindOfClass:UINavigationController.class]) {
        UIViewController *topViewController = [(UINavigationController *)rootViewCoontroller topViewController];
        UIViewController *viewController = topViewController;
        if ([topViewController isKindOfClass:UITabBarController.class]) {
            viewController = [(UITabBarController *)topViewController selectedViewController];
        }

        [viewController rendererWeex];

    }

}
@end
