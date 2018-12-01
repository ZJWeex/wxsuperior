//
//  TCMLocationAuth.h
//  Pods
//
//  Created by Dao on 2018/1/10.
//

#import <Foundation/Foundation.h>

#import "tcmlog.h"


/**
 * 定位相关的鉴权
 */
@interface TCMLocationAuth : NSObject


/**
 * SDK鉴权
 */
+ (void)checkPermision;


/**
 * 检测定位授权
 *
 * @param wakeAuth 未授权时是否提示授权
 * @return YES:授权成功 | 未明确授权     NO:未授权
 */
+ (BOOL)checkLocationAuth:(BOOL)wakeAuth;


/**
 * 检测后台定位授权
 *
 * @param wakeAuth 未授权时是否提示授权
 * @return YES:授权成功 | 未明确授权     NO:未授权
 */
+ (BOOL)checkBackgroundAuth:(BOOL)wakeAuth;

@end
