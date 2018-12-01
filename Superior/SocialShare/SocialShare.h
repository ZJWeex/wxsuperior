//
//  SocialShare.h
//  Superior
//
//  Created by Dao on 2018/7/26.
//  Copyright © 2018 淘菜猫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialShareMessage.h"



@interface SocialShare : NSObject


/**
 *  独立设置时请放置到Message设置之后
 */

+ (void)sendMessage:(SocialShareMessage *)message;
+ (void)sendMessage:(SocialShareMessage *)message delegate:(id<SocialShareRespondDelegate>)delegate;
+ (void)sendMessage:(SocialShareMessage *)message respondBlock:(SocialShareRespondBlock)respondBlock;

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
@end
