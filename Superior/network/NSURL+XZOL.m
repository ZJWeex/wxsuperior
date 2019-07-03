//
//  NSURL+XZOL.m
//  Knowledge
//
//  Created by Dao on 2018/7/17.
//  Copyright © 2018 XueZhiOnline. All rights reserved.
//

#import "NSURL+XZOL.h"
#import "NSObject+tHybridURL.h"


@implementation NSURL (XZOL)

+ (NSURL *)weexUrlWithFilePath:(NSString *)filePath{

    NSString *fullpath = nil;
#if DEBUG
//    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
//    NSString *basePath = [NSString stringWithFormat:@"%@/dist/base-superior/",mainBundlePath];
//    fullpath = [NSString stringWithFormat:@"%@%@", basePath, filePath];
//    return [NSURL fileURLWithPath:fullpath isDirectory:YES];
#endif
    fullpath = [NSString stringWithFormat:@"%@%@", [filePath tHybridRemoteBaseURL], filePath];
    return [NSURL URLWithString:fullpath];

}


@end
