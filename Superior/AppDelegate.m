//
//  AppDelegate.m
//  Superior
//
//  Created by Dao on 2018/4/27.
//  Copyright © 2018 淘菜猫. All rights reserved.
//

#import "AppDelegate.h"
#import <tHybridKit.h>
#import "TCMLocationManager.h"

#import "SocialShare.h"

#import <QQSDK/TencentOpenAPI/TencentOAuth.h>
#import "TCMAppKeyManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "GDPaymentSystem.h"
#import <GTSDK/GeTuiSdk.h>
// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#import <AFNetworkReachabilityManager.h>

#define kGtAppId           @"k9t8bwWikT9b1Z5MLt42AA"
#define kGtAppKey          @"mYhDnIpU598JbOXagf8mR9"
#define kGtAppSecret       @"ROth784hla7Md0hM7zo1T3"


@interface AppDelegate ()<UIApplicationDelegate, GeTuiSdkDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [tHybridKit launchingWeex];
    [[TCMLocationManager instance] registerWithKey:@"nKXN3Kn5u5GbC1U8GRcFbUKu" result:^(BMKLocationAuthErrorCode authCode) {
        if (authCode == BMKLocationAuthErrorSuccess) {
            
        }
    }];
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    // 注册 APNs
    [self registerRemoteNotification];

    AFNetworkReachabilityManager *afManager = [AFNetworkReachabilityManager sharedManager];
    [afManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {

    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkMonitor:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [afManager startMonitoring];

    sleep(1);

    return YES;
}

- (void)networkMonitor:(NSNotification *)noti{

    switch ((AFNetworkReachabilityStatus)[noti.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue]) {
        case AFNetworkReachabilityStatusNotReachable:
        case AFNetworkReachabilityStatusUnknown:
            tHybridKit.Thybrid_Kit_Network_Working = NO;
            break;

        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            tHybridKit.Thybrid_Kit_Network_Working = YES;
        default:
            break;
    }
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    //6.3的新的API
    switch ([TCMAppKeyManager ThirdPartySourceVerification:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]]) {
        case ThirdPartySourceOptionAli_Pay:
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                [GDPaymentSystem aliPayCallback:resultDic];
            }];
            break;
        case ThirdPartySourceOptionWeChat_Shared:
        case ThirdPartySourceOptionQQ_Shared:
        case ThirdPartySourceOptionWeChat_Pay:
                [SocialShare application:app openURL:url options:options];
            break;
        case ThirdPartySourceOptionUnknown:
#if DEBUG
            [CESHelper showPromptHUBWithMsg:[NSString stringWithFormat:@"%@",[url query]]];
#endif
            break;
    }
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);

    // 向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    NSLog(@"%@", error);
}


/** 注册 APNs */
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */

    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

@end
