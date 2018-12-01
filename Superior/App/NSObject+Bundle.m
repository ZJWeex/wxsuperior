//
//  NSObject+Bundle.m
//  Buyer
//
//  Created by Dao on 2018/6/4.
//  Copyright © 2018 Taocaimall Inc. All rights reserved.
//

#import "NSObject+Bundle.h"

@implementation NSObject (Bundle)

- (NSString *)bundleDisplayName{
    return  [NSObject bundleDisplayName];
}
+ (NSString *)bundleDisplayName{

    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];

    NSString *bundleDisplayName = [info valueForKey:@"CFBundleDisplayName"];

    return bundleDisplayName;
}

- (NSString *)appStoreUrl{
    return [NSObject appStoreUrl];
}

+ (NSString *)appStoreUrl{
#ifdef BUYER_APP_STORE
    return [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id1012946513"];//1012946513
#else
    return [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id1331326278"];
#endif
}

- (NSString *)bundleVersion{
    return [NSObject bundleVersion];
}

+ (NSString *)bundleVersion{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersionStr = [infoDict objectForKey:@"CFBundleShortVersionString"];

    return currentVersionStr;
}

- (NSString *)bundleBuildVersion{
    return [NSObject bundleBuildVersion];
}
+ (NSString *)bundleBuildVersion{
    return [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey];
}

- (NSString *)bundleIdentifier{
    return [NSObject bundleIdentifier];
}
+ (NSString *)bundleIdentifier{
    return [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey];
}

@end
