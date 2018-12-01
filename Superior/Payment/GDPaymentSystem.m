//
//  GDPaymentSystem.m
//  TCMDemo
//
//  Created by Dao on 16/7/13.
//  Copyright © 2016年 光典. All rights reserved.
//

#import "GDPaymentSystem.h"

#import <AlipaySDK/AlipaySDK.h>
#import "GDWechatPayment.h"
#import "TCMAppKeyManager.h"
#import <TCMNetWorking.h>

#import "SocialShare.h"

const NSString *TAOCAIMALL_APP_PAYMENT_NOTIFICATION = @"Taocaimall_APP_Payment_Notification";

@implementation GDPaymentSystem


void (^_tcm_paymentSuccessed)(NSObject *obj) = nil;
void (^_tcm_paymentFailed)(NSObject *obj) = nil;
NSDictionary *_orderData = nil;
+ (void)payWithTyep:(GDPaymentType)payType
          orderData:(NSDictionary *)orderData
   paymentSuccessed:(void (^)(NSString *message))paymentSuccessed
      paymentFailed:(void (^)(NSString *message))paymentFailed
{
    [self Cancel];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *urlTypes = [infoDict objectForKey:@"CFBundleURLTypes"];
    NSArray *urlSchemes = [urlTypes[0] objectForKey:@"CFBundleURLSchemes"];
    NSString *appScheme = urlSchemes[0];

    _tcm_paymentSuccessed = [paymentSuccessed copy];
    _tcm_paymentFailed = [paymentFailed copy];
    _orderData = orderData;

    if (GDPaymentTypeAlipay == payType) {
        [[AlipaySDK defaultService] payOrder:[orderData valueForKey:@"payUrl"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            [self aliPayCallback:resultDic];
         }];
    } else if (GDPaymentTypeWechat == payType) {
        SocialShareMessage *msg = [SocialShareMessage payMessage:[orderData valueForKey:@"payParams"] platform:(SocialSharePlatform_WeChat_Session)];
        [SocialShare sendMessage:msg respondBlock:^(SocialShareResp *resp) {
            if (!_tcm_paymentSuccessed || !_tcm_paymentFailed) {
                return ;
            }
            if (resp) {
                switch (resp.result) {
                    case SocialShareResultCodeSuccess:
                        _tcm_paymentSuccessed(@"支付成功");
                        break;
                    case SocialShareResultCodeUserCancel:
                        _tcm_paymentFailed(@"已取消支付");
                        break;
                    default:
                        if (resp.msg.length) {
                            _tcm_paymentFailed(resp.msg);
                        } else {
                            _tcm_paymentFailed(@"支付失败");
                        }
                        break;
                }
            } else {
                _tcm_paymentFailed(@"订单异常，拉起支付失败！");
            }
            [self Cancel];
        }];

    }

}

+ (void)Cancel{
    _tcm_paymentSuccessed = nil;
    _tcm_paymentFailed = nil;
}

+ (void)aliPayCallback:(NSDictionary *)resultDic{
    if (!_tcm_paymentSuccessed || !_tcm_paymentFailed) {
        return ;
    }
    NSString *resultStatuStr = [NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]];
    //                 返回码    含义
    //                 9000    订单支付成功
    //                 8000    正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
    //                 4000    订单支付失败
    //                 5000    重复请求
    //                 6001    用户中途取消
    //                 6002    网络连接出错
    //                 6004    支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
    //                 其它    其它支付错误
    switch (resultStatuStr.integerValue) {
        case 9000:
            _tcm_paymentSuccessed(@"支付成功");
            break;
        case 4000:
        case 6002:
            _tcm_paymentFailed(@"支付失败，请重试");
            break;
        case 6001:
            _tcm_paymentFailed(@"已取消支付");
            break;
        default:
            _tcm_paymentFailed(@"支付订单正在处理中");
            break;
    }
    [self Cancel];
}


WX_EXPORT_METHOD(@selector(Pay:callback:));
- (void)Pay:(NSDictionary *)option callback:(WXModuleCallback)callback{

    NSString *payType = [option valueForKey:@"payType"]; //'aliPay'||'wechatPay'
    GDPaymentType theType = GDPaymentTypeCMBC;
    if ([payType isEqualToString:@"alipay"]) {
        theType = GDPaymentTypeAlipay;
    } else if ([payType isEqualToString:@"weChatpay"]) {
        theType = GDPaymentTypeWechat;
    }

    [GDPaymentSystem payWithTyep:theType orderData:option paymentSuccessed:^(NSString *message) {
        if (callback) {
            callback(@{
                       @"code": @"0",
                       @"msg":message,
                       });
        }

    } paymentFailed:^(NSString *message) {
        if (callback) {
            callback(@{
                       @"code": @"1",
                       @"msg":message,
                       });
        }
    }];
}


@end
