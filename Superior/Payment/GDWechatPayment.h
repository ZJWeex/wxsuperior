//
//  GDWechatPayment.h
//  TCMDemo
//
//  Created by TonyLiu on 16/7/27.
//  Copyright © 2016年 光典. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WXApi.h>
#import <WXApiObject.h>

typedef void(^GDWechatCompletionBlock)(PayResp *payResp);

@interface GDWechatPayment : NSObject<WXApiDelegate>

+ (GDWechatPayment*)sharedWechatPayment;

- (void)wechatPayRequest:(NSDictionary*)payRequsetDic callBack:(GDWechatCompletionBlock)completionBlock isWXNotInstalled:(void(^)(void))installedHandler;

@end
