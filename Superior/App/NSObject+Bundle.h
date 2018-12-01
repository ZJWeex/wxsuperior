//
//  NSObject+Bundle.h
//  Buyer
//
//  Created by Dao on 2018/6/4.
//  Copyright © 2018 Taocaimall Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworkReachabilityManager.h>

@interface NSObject (Bundle)


/**
 *  APP名称
 */
@property (nonatomic, copy, readonly) NSString *bundleDisplayName;
@property (class, nonatomic, copy, readonly) NSString *bundleDisplayName;


/**
 *  AppStore预览页
 */
@property (nonatomic, copy, readonly) NSString *appStoreUrl;
@property (class, nonatomic, copy, readonly) NSString *appStoreUrl;


/**
 *  APP版本号
 */
@property (nonatomic, copy, readonly) NSString *bundleVersion;
@property (class, nonatomic, copy, readonly) NSString *bundleVersion;


/**
 *  APP Build号
 */
@property (nonatomic, copy, readonly) NSString *bundleBuildVersion;
@property (class, nonatomic, copy, readonly) NSString *bundleBuildVersion;

@property (nonatomic, copy, readonly) NSString *bundleIdentifier;
@property (class, nonatomic, copy, readonly) NSString *bundleIdentifier;


@end
