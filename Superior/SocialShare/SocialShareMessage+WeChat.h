//
//  SocialShareMessage+WeChat.h
//  Superior
//
//  Created by Dao on 2018/7/27.
//  Copyright © 2018 淘菜猫. All rights reserved.
//

#import "SocialShareMessage.h"

#import <WXApi.h>
#import <WechatAuthSDK.h>

@interface SocialShareMessage (WeChat)

- (BaseReq *)WeChatMessage;

@end
