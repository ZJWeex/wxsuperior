//
//  TCMLocationManager.m
//  Expecta
//
//  Created by Dao on 2018/1/9.
//

#import "TCMLocationManager.h"

//单次定位
#import <BMKLocationKit/BMKLocationComponent.h>

#import "TCMLocationAuth.h"
#import "TCMLocation.h"

static BMKLocation *kLastLocation = nil;


@interface TCMLocationManager()<BMKLocationManagerDelegate>

@property (nonatomic, strong) BMKLocationManager *manager;

@property (nonatomic, copy) tcm_location_once_t block;

@end

@implementation TCMLocationManager

/**
 *  调用之前请先在info.plist中配置ak,
 *     ak的Key，请参考TCMBaiduLocationAK的定义
 *
 *  @param wakeAuth 是否唤醒授权
 */
+ (void)launchingSDK:(BOOL)wakeAuth{
    [TCMLocationAuth checkPermision];
    tcm_location_once(^(TCMLocation *location){
    }, wakeAuth);
}

- (instancetype)init{
    if (self = [super init]) {
        _manager = [[BMKLocationManager alloc] init];

        //初始化实例
        _manager = [[BMKLocationManager alloc] init];
        //设置delegate
        _manager.delegate = self;
        //设置返回位置的坐标系类型
        _manager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设置距离过滤参数
        _manager.distanceFilter = 1;
        //设置预期精度参数
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置应用位置类型
        _manager.activityType = CLActivityTypeAutomotiveNavigation;
        //设置是否自动停止位置更新
        _manager.pausesLocationUpdatesAutomatically = NO;
        //设置是否允许后台定位
        _manager.allowsBackgroundLocationUpdates = NO;
        //设置位置获取超时时间
        _manager.locationTimeout = 10;
        //设置获取地址信息超时时间
        _manager.reGeocodeTimeout = 10;
        //定位数据中是否返回地址数据
        _manager.locatingWithReGeocode = YES;
    }
    return self;
}

+ (instancetype)sharedInstance{
    static TCMLocationManager *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[self alloc] init];
    });

    return handler;
}

#pragma mark- <BMKLocationManagerDelegate>
/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 BMKLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error{

}


/**
 *  @brief 连续定位回调函数。
 *  @param manager 定位 BMKLocationManager 类。
 *  @param location 定位结果，参考BMKLocation。
 *  @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error{
    if (self.block) {
        self.block(location);
    }
    kLastLocation = location;
}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 BMKLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"定位权限被修改：%@", @(status));
}


/**
 * @brief 该方法为BMKLocationManager提示需要设备校正回调方法。
 * @param manager 提供该定位结果的BMKLocationManager类的实例。
 */
- (BOOL)BMKLocationManagerShouldDisplayHeadingCalibration:(BMKLocationManager * _Nonnull)manager{
    return NO;
}

/**
 * @brief 该方法为BMKLocationManager提供设备朝向的回调方法。
 * @param manager 提供该定位结果的BMKLocationManager类的实例
 * @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
          didUpdateHeading:(CLHeading * _Nullable)heading{

}

/**
 * @brief 该方法为BMKLocationManager所在App系统网络状态改变的回调事件。
 * @param manager 提供该定位结果的BMKLocationManager类的实例
 * @param state 当前网络状态
 * @param error 错误信息
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
     didUpdateNetworkState:(BMKLocationNetworkState)state orError:(NSError * _Nullable)error{
    if (error) {
        NSLog(@"%@", error);
        return;
    }

    NSString *msg = nil;
    switch (state) {
            case BMKLocationNetworkStateUnknown:
            msg = @"BMKLocationNetworkStateUnknown = 0,    ///<网络状态未知";
            case BMKLocationNetworkStateWifi:
            msg = @"BMKLocationNetworkStateWifi,           ///<网络状态wifi";
            break;
            case BMKLocationNetworkStateWifiHotSpot:
            msg = @"BMKLocationNetworkStateWifiHotSpot,          ///<网络状态连接WIFI移动热点";
            break;
            case BMKLocationNetworkStateMobile2G:
            msg = @"BMKLocationNetworkStateMobile2G,          ///<网络状态移动2G";
            break;
            case BMKLocationNetworkStateMobile3G:
            msg = @"BMKLocationNetworkStateMobile3G,          ///<网络状态移动3G";
            break;
            case BMKLocationNetworkStateMobile4G:
            msg = @"BMKLocationNetworkStateMobile4G        ///<网络状态移动4G";
            break;
    }

    NSLog(@"%@", msg);
}

+ (TCMLocation *)lastLocation{
    return kLastLocation;
}

@end



/**
 * 进行一次定位
 *
 *  · 成功获取定位信息后，rgcData可能为空（eg. 手机无网状态）
 * @param block 异步返回定位结果
 */
void _tcm_location_once(tcm_location_once_t block, BOOL wakeAuth){
    [TCMLocationAuth checkLocationAuth:wakeAuth];
    [[TCMLocationManager sharedInstance].manager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
#ifdef DEBUG
        if (location.location && !location.rgcData) {
            NSLog(@"地址信息缺失，定位失败");
        }
#endif
        kLastLocation = location;
        block(location);
    }];
}


/**
 * 停止定位
 */
void _tcm_location_stop(void){
    TCMLocationManager *manager = [TCMLocationManager sharedInstance];
    manager.block = nil;
    manager.manager.allowsBackgroundLocationUpdates = NO;
    [manager.manager stopUpdatingLocation];
}

/**
 * 开启持续定位
 *
 * @param block 异步返回定位结果
 */
void _tcm_location_roll(tcm_location_once_t block, BOOL wakeAuth){
    [TCMLocationAuth checkLocationAuth:wakeAuth];
    TCMLocationManager *manager = [TCMLocationManager sharedInstance];
    manager.block = block;
    [manager.manager startUpdatingLocation];
}


/**
 * 开启后台定位定位
 *
 * @param block 异步返回定位结果
 */
void _tcm_location_background(tcm_location_once_t block, BOOL wakeAuth){
    //后台定位权限检测
    if (![TCMLocationAuth checkBackgroundAuth:wakeAuth]) {
        NSLog(@"无后台定位权限");
        return;
    }

    //开启后台定位权限
    TCMLocationManager *manager = [TCMLocationManager sharedInstance];
    manager.manager.allowsBackgroundLocationUpdates = YES;
    _tcm_location_roll(block, wakeAuth);
}
