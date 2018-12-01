//
//  TCMLocationManager.h
//  Expecta
//
//  Created by Dao on 2018/1/9.
//

#import <Foundation/Foundation.h>

#import <BMKLocationKit/BMKLocation.h>

/**
 * 定位系统数据模型，具体参考tcm_location_once
 */
typedef BMKLocation TCMLocation;


/**
 * 定位结果block定义
 *
 * @param location 定位数据
 */
typedef void (^tcm_location_once_t)(TCMLocation * location);

/**
 * 进行一次定位
 *
 *  · 成功获取定位信息后，rgcData可能为空（eg. 手机无网状态）
 * @param block 异步返回定位结果
 */
void _tcm_location_once(tcm_location_once_t block, BOOL wakeAuth);


/**
 * 停止定位
 */
void _tcm_location_stop(void);

/**
 * 开启持续定位
 *
 * @param block 异步返回定位结果
 */
void _tcm_location_roll(tcm_location_once_t block, BOOL wakeAuth);

/**
 * 开启后台定位定位
 *
 * @param block 异步返回定位结果
 */
void _tcm_location_background(tcm_location_once_t block, BOOL wakeAuth);



/**
 * 定位管理控制器
 */
@interface TCMLocationManager : NSObject

/**
 *  调用之前请先在info.plist中配置ak,
 *     ak的Key，请参考TCMBaiduLocationAK的定义
 *
 *  @param wakeAuth 是否唤醒授权
 */
+ (void)launchingSDK:(BOOL)wakeAuth;

+ (TCMLocation *)lastLocation;

@end
