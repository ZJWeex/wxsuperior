//
//  TCMLocation.h
//  Expecta
//
//  Created by Dao on 2018/1/9.
//

/**
 *  基于百度定位SDK进行封装的定位工具集
 *
 */

/*info.plist文件中AK的键值，可通过查询定义或者log输出查询*/
FOUNDATION_EXTERN NSString *const TCMBaiduLocationAK;

#import <Foundation/Foundation.h>
#import <TCMLocationManager.h>

//进行一次定位
#define tcm_location_once   _tcm_location_once
//停止定位
#define tcm_location_stop   _tcm_location_stop
//开启持续定位
#define tcm_location_roll   _tcm_location_roll
//开启后台定位定位
#define tcm_location_background _tcm_location_background


