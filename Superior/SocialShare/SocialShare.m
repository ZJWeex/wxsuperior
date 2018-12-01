//
//  SocialShare.m
//  Superior
//
//  Created by Dao on 2018/7/26.
//  Copyright © 2018 淘菜猫. All rights reserved.
//

#import "SocialShare.h"

#import <WXApi.h>
#import <QQSDK/TencentOpenAPI/QQApiInterface.h>
#import <QQSDK/TencentOpenAPI/TencentOAuth.h>
#import "TCMAppKeyManager.h"

@interface SocialShareHandler : NSObject <WXApiDelegate, QQApiInterfaceDelegate, TencentSessionDelegate>

@property (nonatomic, strong) SocialShareMessage *message;
@property (class, nonatomic, readonly) SocialShareHandler *handler;

@property (nonatomic, weak) id<SocialShareRespondDelegate> delegate;
@property (nonatomic, copy) SocialShareRespondBlock  respondBlock;

- (void)sendMessage:(SocialShareMessage *)message delegate:(id<SocialShareRespondDelegate>)delegate respondBlock:(SocialShareRespondBlock)respondBlock;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
@end



@implementation SocialShare


+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [SocialShareHandler.handler application:app openURL:url options:options];
}


+ (void)sendMessage:(SocialShareMessage *)message{
    [SocialShareHandler.handler sendMessage:message delegate:message.delegate respondBlock:message.respondBlock];
}

+ (void)sendMessage:(SocialShareMessage *)message delegate:(id<SocialShareRespondDelegate>)delegate{
    [SocialShareHandler.handler sendMessage:message delegate:delegate respondBlock:nil];
}

+ (void)sendMessage:(SocialShareMessage *)message respondBlock:(SocialShareRespondBlock)respondBlock{
    [SocialShareHandler.handler sendMessage:message delegate:nil respondBlock:respondBlock];
}


@end

@interface SocialShareHandler ()

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation SocialShareHandler

static SocialShareHandler *SocialShareHandler_Instance = nil;

+ (SocialShareHandler *)handler{
    if (!SocialShareHandler_Instance) {
        SocialShareHandler_Instance = [[SocialShareHandler alloc] init];

        [WXApi registerApp:[TCMAppKeyManager idForSDK:(TCMIntegrateSDKTypeWX)] enableMTA:YES];

        SocialShareHandler_Instance.tencentOAuth = [[TencentOAuth alloc] initWithAppId:[TCMAppKeyManager idForSDK:(TCMIntegrateSDKTypeQQ)] andDelegate:SocialShareHandler_Instance];
        SocialShareHandler_Instance.tencentOAuth.redirectURI = @"www.qq.com";
    }
    return SocialShareHandler_Instance;
}

- (void)sendMessage:(SocialShareMessage *)message delegate:(id<SocialShareRespondDelegate>)delegate respondBlock:(SocialShareRespondBlock)respondBlock{
    if (!message) {
        NSLog(@"SocialShare 分享数据不能为空");
        return;
    }
    if (delegate || respondBlock) {
        self.message = message;
    }
    self.delegate = delegate;
    self.respondBlock = respondBlock;

    switch (message.platform) {
        case SocialSharePlatform_WeChat_Session:
        case SocialSharePlatform_WeChat_Timeline:
            if (![WXApi isWXAppInstalled]) {
                SocialShareResp *ShareResp = [[SocialShareResp alloc] init];
                ShareResp.result = SocialShareResultCodeSentFail;
                ShareResp.msg = @"未安装微信";
                [self sendMessageToHandler:ShareResp];
                return;
            }
            if (![WXApi sendReq:message.message]) {
                    SocialShareResp *ShareResp = [[SocialShareResp alloc] init];
                    ShareResp.result = SocialShareResultCodeSentFail;
                if (message.shareType == SocialShareTypePay) {
                    ShareResp.msg = @"拉起支付失败";
                } else {
                    ShareResp.msg = @"分享失败";
                }
                    [self sendMessageToHandler:ShareResp];
            }
            break;
        case SocialSharePlatform_QQ_Zone:
            [QQApiInterface SendReqToQZone:message.message];
            break;
        case SocialSharePlatform_QQ_Session:{
            if (message.shareType == SocialShareTypeAuth) {
                self.message = message;
                [self.tencentOAuth authorize:message.message];
            } else {
                [QQApiInterface sendReq:message.message];

            }

        }
            break;
        case SocialShareMessage_Unknow:
            NSLog(@"无法识别所选择的分享平台");
            break;
    }

}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{

    SocialSharePlatform platform = self.message.platform;

    switch (platform) {
        case SocialSharePlatform_WeChat_Timeline:
        case SocialSharePlatform_WeChat_Session:
            [WXApi handleOpenURL:url delegate:self];
            break;
        case SocialSharePlatform_QQ_Session:
        case SocialSharePlatform_QQ_Zone:
            if (self.message.shareType == SocialShareTypeAuth) {
                return [TencentOAuth HandleOpenURL:url];
            } else {
                return [QQApiInterface handleOpenURL:url delegate:self];
            }
            break;
        case SocialShareMessage_Unknow:
            break;
    }

    return NO;
}

//响应微信请求
- (void)onReq:(BaseReq *)req{

}

//响应微信反馈
- (void)onResp:(BaseResp *)resp{
    SocialShareResp *ShareResp = [[SocialShareResp alloc] init];
    ShareResp.result = resp.errCode;
    ShareResp.msg = resp.errStr;
    switch (self.message.shareType) {
        case SocialShareTypeAuth:
            break;
        case SocialShareTypePay:
        default:
            [self sendMessageToHandler:ShareResp];
            break;
    }

    self.message = nil;
}

- (void)sendMessageToHandler:(SocialShareResp *)ShareResp{
    if ([self.delegate respondsToSelector:@selector(socialShareRespond:)]) {
        [self.delegate socialShareRespond:ShareResp];
    } else if (self.respondBlock) {
        self.respondBlock(ShareResp);
    } else if (ShareResp.msg.length){
        [CESHelper showPromptHUBWithMsg:ShareResp.msg];
    }
    self.delegate = nil;
    self.respondBlock = nil;
}

- (void)tencentDidLogin{
    NSLog(@"授权成功");
}
- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"授权失败");
}
@end
