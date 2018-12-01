//
//  GDPaymentTypeModel.m
//  TCMDemo
//
//  Created by TonyLiu on 16/7/6.
//  Copyright © 2016年 光典. All rights reserved.
//

#import "GDPaymentTypeModel.h"

@implementation GDPaymentTypeModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self == [super init]) {
        
        _paymentTypeStr = dictionary[@"payType"];
        
        _paymentType = [self paymentTypeWith:dictionary[@"payType"]];
        
        _paymentTypeName = dictionary[@"payTypeName"];
        
        _paymentTypeIconUrl = [NSURL URLWithString:dictionary[@"iconUrl"]];
    }
    
    return self;
}

- (GDPaymentType)paymentTypeWith:(NSString*)paymentTypeStr
{
    GDPaymentType currentPaymentType = GDPaymentTypeAlipay;
    
    if ([paymentTypeStr isEqualToString:@"alipay"]) {
        
        currentPaymentType = GDPaymentTypeAlipay;
        
    }else if ([paymentTypeStr isEqualToString:@"weChatpay"]){
        
        currentPaymentType = GDPaymentTypeWechat;
        
    }else if ([paymentTypeStr isEqualToString:@"cmbpay"]){
        
        currentPaymentType = GDPaymentTypeCMBC;
    }
    
    return currentPaymentType;
}



+ (instancetype)paymentWithType:(GDPaymentType)paymentType{
    GDPaymentTypeModel *model = [[GDPaymentTypeModel alloc] init];

    switch (paymentType) {
        case GDPaymentTypeAlipay:
            model.paymentTypeName = @"支付宝支付";
            model.paymentTypeStr = @"alipay";
            break;
        case GDPaymentTypeWechat:
            model.paymentTypeName = @"微信支付";
            model.paymentTypeStr = @"weChatpay";
            break;
        case GDPaymentTypeCMBC:
            model.paymentTypeName = @"银行卡支付";
            model.paymentTypeStr = @"cmbpay";
            break;
    }
    return model;
}


@end
