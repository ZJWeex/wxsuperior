//
//  TCMAppKeyManager.h
//  TCMDemo
//
//  Created by JL on 2016/12/4.
//  Copyright © 2016年 Taocaimall Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TCMAppKeyManager : NSObject

typedef NS_ENUM(NSInteger, TCMIntegrateSDKType)
{
    /**微信SDK*/
    TCMIntegrateSDKTypeWX           = 0,
    /**QQ SDK*/
    TCMIntegrateSDKTypeQQ           = 1,
    /**AliPay SDK*/
    TCMIntegrateSDKTypeAliPay       = 2,
    /**Baidu地图 SDK*/
    TCMIntegrateSDKTypeBaidu_Map    = 3,
    /**个推 SDK*/
    TCMIntegrateSDKTypeGeTui        = 5,
    /**小能 SDK*/
    TCMIntegrateSDKTypeXN           = 6,
    /**友盟 SDK*/
    TCMIntegrateSDKTypeUM           = 7,
    /**RCloud SDK*/
    TCMIntegrateSDKTypeRCloud       = 8,
    /**TalkingData SDK*/
    TCMIntegrateSDKTypeTalkingData  = 9,
    /**TCM 支付设置*/
    TCMIntegrateSDKTypeTCM  = 10,
    /**Baidu语音识别 SDK*/
    TCMIntegrateSDKTypeBaidu_ASR  = 11,
    /** 位置来源 **/
    TCMIntegrateSDKTypeUnKnow,
};
+ (NSString *)idForSDK:(TCMIntegrateSDKType)sdk;
+ (NSString *)secretForSDK:(TCMIntegrateSDKType)sdk;
+ (NSString *)keyForSDK:(TCMIntegrateSDKType)sdk;


typedef NS_ENUM(NSInteger, ThirdPartySourceOption)
{
    /**未知来源*/
    ThirdPartySourceOptionUnknown = 0,
    /**微信-支付返回*/
    ThirdPartySourceOptionWeChat_Pay,
    /**微信-分享*/
    ThirdPartySourceOptionWeChat_Shared,
    /**QQ-分享*/
    ThirdPartySourceOptionQQ_Shared,
    /**支付宝-支付*/
    ThirdPartySourceOptionAli_Pay,
};
/**
 第三方唤醒APP检测

 @param url 唤醒APP的URL
 @param sourceApplication 唤醒程序
 @return 唤醒方标识
 */
+ (ThirdPartySourceOption)ThirdPartySourceVerification:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
