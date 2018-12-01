//
//  TCMWeex.h
//  Weex
//
//  Created by Dao on 2018/1/9.
//  Copyright © 2018年 Taocaimall. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  启动Weex
 *    所需配置表：weexConfiguration.plist <module, class>
 */
@interface tHybridKit : NSObject

@property (class, nonatomic, assign) NSInteger Thybrid_Kit_Network_Working;
@property (class, nonatomic, assign, readonly) BOOL Thybrid_Kit_Iphone_X;

+ (void)launchingWeex;

+ (void)launchingWeex:(NSString *)env;


@end
