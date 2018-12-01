//
//  TCMAppKeyManager.m
//  TCMDemo
//
//  Created by JL on 2016/12/4.
//  Copyright © 2016年 Taocaimall Inc. All rights reserved.
//

#import "TCMAppKeyManager.h"


typedef NSString const* TCMIntegrateSDKIdentifierType;
@implementation TCMAppKeyManager

static NSDictionary *sTCMSDKTypeConfig = nil;
static NSDictionary *sTCMKeyTypeConfig = nil;
static NSString *sTCMBouldID = nil;

NSString const *TCMIntegrateSDKIdentifierTypeAPPID = @"AppId";
NSString const *TCMIntegrateSDKIdentifierTypeAPPSECRET = @"AppSecret";
NSString const *TCMIntegrateSDKIdentifierTypeAPPKEY = @"AppKey";

+ (void)load{
    [super load];

    sTCMSDKTypeConfig = @{
                          @(TCMIntegrateSDKTypeWX):@"WX",
                          @(TCMIntegrateSDKTypeQQ):@"QQ",
                          @(TCMIntegrateSDKTypeAliPay):@"AliPay",
                          @(TCMIntegrateSDKTypeBaidu_Map):@"Baidu_Map",
                          @(TCMIntegrateSDKTypeGeTui):@"GeTui",
                          @(TCMIntegrateSDKTypeXN):@"XN",
                          @(TCMIntegrateSDKTypeUM):@"UM",
                          @(TCMIntegrateSDKTypeRCloud):@"RCloud",
                          @(TCMIntegrateSDKTypeTalkingData):@"TalkingData",
                          @(TCMIntegrateSDKTypeTCM):@"TCM",
                          @(TCMIntegrateSDKTypeBaidu_ASR):@"Baidu_ASR",
                          };

    sTCMBouldID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}


+ (NSString *)valueForKeyType:(TCMIntegrateSDKIdentifierType)keyTypeStr forSDK:(TCMIntegrateSDKType)sdkType{
    NSString *sdkTypeStr = [sTCMSDKTypeConfig objectForKey:@(sdkType)];
    NSLog(@"sdkTypeStr:%@", sdkTypeStr);

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:sdkTypeStr ofType:@"plist"];
    NSDictionary *appKeyConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    NSDictionary *keyDicForBID = [appKeyConfig objectForKey:sTCMBouldID];
    keyDicForBID = keyDicForBID?:appKeyConfig;
    NSLog(@"keyDicForBID:%@", keyDicForBID);
    
    NSString *value = nil;
#if (TCM_NETWORK_SERVICE_PLATFORM_IS_PRODUCTION)
    value = [keyDicForBID objectForKey:keyTypeStr];
#else
    NSString *debugStr = [NSString stringWithFormat:@"%@.debug", keyTypeStr];
    
    value = [keyDicForBID objectForKey:debugStr];
    if (!value) {
        value = [keyDicForBID objectForKey:keyTypeStr];
    }
#endif
    
    return value;
}

+ (NSString *)idForSDK:(TCMIntegrateSDKType)sdk{
    return [self valueForKeyType:(TCMIntegrateSDKIdentifierTypeAPPID) forSDK:sdk];
}
+ (NSString *)secretForSDK:(TCMIntegrateSDKType)sdk{
    return [self valueForKeyType:(TCMIntegrateSDKIdentifierTypeAPPSECRET) forSDK:sdk];
}
+ (NSString *)keyForSDK:(TCMIntegrateSDKType)sdk{
    return [self valueForKeyType:(TCMIntegrateSDKIdentifierTypeAPPKEY) forSDK:sdk];
}

+ (ThirdPartySourceOption)ThirdPartySourceVerification:(NSURL *)url sourceApplication:(NSString *)sourceApplication{

    NSString *absoluteString = url.absoluteString;
    NSArray<NSString *> *formatURL = [absoluteString componentsSeparatedByString:@"://"];
    //Ali数据原
    if ([sourceApplication isEqualToString:@"com.alipay.iphoneclient"]) {
        return ThirdPartySourceOptionAli_Pay;
    } else if ([sourceApplication isEqualToString:@"com.tencent.xissn"] || [formatURL.firstObject hasSuffix:[self idForSDK:(TCMIntegrateSDKTypeWX)]]) {
        //微信数据源

        if ([url.host isEqualToString:@"pay"]) {
            return ThirdPartySourceOptionWeChat_Pay;
        }
        return ThirdPartySourceOptionWeChat_Shared;
    } else if ([sourceApplication isEqualToString:@"com.tencent.mqq"] || [formatURL.firstObject hasSuffix:[self idForSDK:(TCMIntegrateSDKTypeQQ)]]) {
        //QQ数据源
        return ThirdPartySourceOptionQQ_Shared;
    } else if ([formatURL.firstObject isEqualToString:self.bundleIdentifier]){
        if ([url.host isEqualToString:@"safepay"]) {
            return ThirdPartySourceOptionAli_Pay;
        }
        return ThirdPartySourceOptionUnknown;
    }

    return ThirdPartySourceOptionUnknown;
}
@end
