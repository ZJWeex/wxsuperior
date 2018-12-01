//
//  GDPaymentTypeModel.h
//  TCMDemo
//
//  Created by TonyLiu on 16/7/6.
//  Copyright © 2016年 光典. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  支付方式
 */
typedef NS_ENUM(NSInteger, GDPaymentType) {
    /**
     *  支付宝
     */
    GDPaymentTypeAlipay = 1,
    /**
     *  微信
     */
    GDPaymentTypeWechat,
    /**
     *  招商银行一网通
     */
    GDPaymentTypeCMBC
};

@interface GDPaymentTypeModel : NSObject

/**支付方式*/
@property (nonatomic, assign) GDPaymentType paymentType;

/**支付字段*/
@property (nonatomic, copy) NSString *paymentTypeStr;

/**支付方式名称*/
@property (nonatomic, copy) NSString *paymentTypeName;

/**支付方式图标url*/
@property (nonatomic, copy) NSURL *paymentTypeIconUrl;

+ (instancetype)paymentWithType:(GDPaymentType)paymentType;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
