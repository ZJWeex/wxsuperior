//
//  GDPaymentSystem.h
//  TCMDemo
//
//  Created by Dao on 16/7/13.
//  Copyright © 2016年 光典. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDPaymentTypeModel.h"

extern NSString *TAOCAIMALL_APP_PAYMENT_NOTIFICATION;

@interface GDPaymentSystem : tHybridKitModule

/**
 支付

 @param option 参数{payType: 'aliPay'||'wechatPay' ,,,,,}其他数据在同级目录['aliPay','wechatPay']
 @param callback 支付回调{code:'0'||'1', msg:''}, '0':支付成功 ‘1’:支付失败
 */
- (void)Pay:(NSDictionary *)option callback:(WXModuleCallback)callback;


+ (void)aliPayCallback:(NSDictionary *)resultDic;
@end
