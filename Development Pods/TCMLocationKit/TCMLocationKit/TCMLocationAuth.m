//
//  TCMLocationAuth.m
//  Pods
//
//  Created by Dao on 2018/1/10.
//

#import "TCMLocationAuth.h"

#import <BMKLocationKit/BMKLocationAuth.h>
#import <CoreLocation/CLLocationManager.h>
#import "TCMAlertView.h"

/**百度定位唯一识别码（Ak）*/
const NSString *const TCMBaiduLocationAK = @"org.cocoapods.demo.TCMLocation-Example.AK";

@interface TCMLocationAuth()<BMKLocationAuthDelegate>


@end

@implementation TCMLocationAuth


/**
 * SDK鉴权的回调协议
 *
 * @param iError 鉴权码
 */
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
    switch (iError) {
        case BMKLocationAuthErrorSuccess:
            NSLog(@"定位系统鉴权成功！");
            break;
        case BMKLocationAuthErrorUnknown:
        case BMKLocationAuthErrorNetworkFailed:
            NSLog(@"定位系统鉴权失败，错误码:%ld", (long)iError);
            break;
        case BMKLocationAuthErrorFailed:
#ifdef DEBUG
            [[[UIAlertView alloc] initWithTitle:@"Location Auth" message:@"The Bundle Identifier does not match the Appkey." delegate:nil cancelButtonTitle:@"I Know" otherButtonTitles:nil, nil] show];
            NSLog(@"定位系统鉴权失败，AK和BID不匹配");
#endif
            break;
    }
}

/**
 * 检测后台定位授权
 *
 * @param wakeAuth 未授权时是否提示授权
 * @return YES:授权成功 | 未明确授权     NO:未授权
 */
+ (BOOL)checkBackgroundAuth:(BOOL)wakeAuth{
    //是否获取过授权
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"用户已关闭系统定位服务");
        return NO;
    }

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"定位系统授权状态码:%d", status);

    NSString *msg =  nil;
    //用户是否已经拒绝定位
    switch (status) {
            case kCLAuthorizationStatusNotDetermined:
            NSLog(@"定位服务尚未拉起授权或用户未选择");
            break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusAuthorizedAlways:
            return YES;
            break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            msg = @"The App needs to access your location information even in background.";
            break;
            case kCLAuthorizationStatusDenied:
            msg = @"The App needs to access your location information when in use.";
            break;
    }

    if (wakeAuth && msg) {
        TCMAlertAction *cancel = [TCMAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:nil];
        TCMAlertAction *confirm = [TCMAlertAction actionWithTitle:@"Goto Setting" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self locationAuth];
        }];

        TCMAlertView *alert = [[TCMAlertView alloc] initWithTitle:@"Location Auth" message:msg];
        [alert addAction:cancel];
        [alert addAction:confirm];
        [alert show];
    }

    return NO;
}


/**
 * 检测定位授权
 *
 * @param wakeAuth 未授权时是否提示授权
 * @return YES:授权成功 | 未明确授权     NO:未授权
 */
+ (BOOL)checkLocationAuth:(BOOL)wakeAuth{
    //是否获取过授权
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"用户已关闭系统定位服务");
        return NO;
    }

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    NSLog(@"定位系统授权状态码:%d", status);

    //用户是否已经拒绝定位
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"定位服务尚未拉起授权或用户未选择");
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YES;
            break;
        case kCLAuthorizationStatusDenied:
            if (wakeAuth) {
                TCMAlertAction *cancel = [TCMAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:nil];
                TCMAlertAction *confirm = [TCMAlertAction actionWithTitle:@"Goto Setting" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    [self locationAuth];
                }];

                TCMAlertView *alert = [[TCMAlertView alloc] initWithTitle:@"Location Auth" message:@"The App needs to access your location information."];
                [alert addAction:cancel];
                [alert addAction:confirm];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
            break;
    }

    return NO;
}


/**
 * 定位授权
 */
+ (void)locationAuth{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


/**
 * SDK鉴权
 * @param ak info.plist中的AK
 */
- (void)checkPermisionWithAK:(NSString *)ak{
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:ak authDelegate:self];
}

/**
 * SDK鉴权
 */
+ (void)checkPermision{
    static TCMLocationAuth *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[TCMLocationAuth alloc] init];
    });
    [handler checkPermisionWithAK:self.checkingAK];
}


/**
 * 获取info.plist配置的AK
 *
 * @return AK
 */
+ (NSString *)checkingAK{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *ak = [infoDict valueForKey:(NSString *)TCMBaiduLocationAK];

    if (!ak.length) {
        NSString *reason = [NSString stringWithFormat:@"Ak undefined. Solve this problem, need to be in the info. The file is defined in a key for the '%@' key/value pair", TCMBaiduLocationAK];
        NSException *exception = [[NSException alloc] initWithName:@"Ak is require" reason:reason userInfo:nil];
        @throw exception;
    } else {
        NSLog(@"\n百度定位唯一识别码（Ak）:{\n%@ : %@\n}", TCMBaiduLocationAK, ak);
    }

    return ak;
}


@end
