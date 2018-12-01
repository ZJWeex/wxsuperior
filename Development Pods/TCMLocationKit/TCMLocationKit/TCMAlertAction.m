//
//  TCMAlertAction.m
//  Pods
//
//  Created by Dao on 2018/1/10.
//

#import "TCMAlertAction.h"

typedef void (^TCMAlertActionBlock)(UIAlertAction *);

@interface TCMAlertAction()

@property (nonatomic, copy) TCMAlertActionBlock block;

@end

@implementation TCMAlertAction

- (id)copyWithZone:(NSZone *)zone{
    TCMAlertAction *action = [super copyWithZone:zone];
    [action.block = self.block copy];
    
    return action;
}


/**
 * 参考UIAlertAction同名方法
 *     ·保存handler对象
 *  @return Action实例对象
 */
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(TCMAlertActionBlock)handler{
    TCMAlertAction *actionObj = [super actionWithTitle:title style:style handler:handler];
    actionObj.block = [handler copy];
    return actionObj;
}


/**
 *  用于TCMAlertView触发用户事件
 */
- (void)action{
    if (self.block) {
        self.block(self);
    }
}

@end
