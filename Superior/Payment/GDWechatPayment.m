//
//  GDWechatPayment.m
//  TCMDemo
//
//  Created by TonyLiu on 16/7/27.
//  Copyright © 2016年 光典. All rights reserved.
//

#import "GDWechatPayment.h"
#import "TCMAppKeyManager.h"

@interface GDWechatPayment ()

@property (nonatomic, strong) GDWechatCompletionBlock completionBlock;

@end

@implementation GDWechatPayment

+ (GDWechatPayment*)sharedWechatPayment
{
    static dispatch_once_t onceToken;
    static GDWechatPayment *instance;
    dispatch_once(&onceToken, ^{
        
        instance = [[GDWechatPayment alloc] init];
    });
    
    return instance;
}

- (void)wechatPayRequest:(NSDictionary *)payRequsetDic callBack:(GDWechatCompletionBlock)completionBlock isWXNotInstalled:(void (^)(void))installedHandler{

    if (payRequsetDic.count == 0) {
        completionBlock(nil);
        
        return;
    }

    [WXApi registerApp:[TCMAppKeyManager idForSDK:TCMIntegrateSDKTypeWX] enableMTA:YES];

    if (![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi]) {
        installedHandler();

        return;
    }

    NSDictionary *paras = payRequsetDic;
    
    PayReq *payReq = [[PayReq alloc] init];
    payReq.partnerId = paras[@"partnerid"];
    payReq.prepayId = paras[@"prepayid"];
    payReq.nonceStr = paras[@"noncestr"];
    payReq.timeStamp = [paras[@"timestamp"] unsignedIntValue];
    payReq.package = paras[@"package"];
    payReq.sign = paras[@"sign"];

    [WXApi sendReq:payReq];

    _completionBlock = completionBlock;

}

/**
 *  微信支付
 *
 *  @param resp 回调
 */
-(void) onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        _completionBlock((PayResp *)resp);
    }
};

@end
