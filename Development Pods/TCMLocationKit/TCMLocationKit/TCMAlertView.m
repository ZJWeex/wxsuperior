//
//  TCMAlertView.m
//  Pods
//
//  Created by Dao on 2018/1/10.
//

#import "TCMAlertView.h"
#import "TCMAlertAction.h"


@interface TCMAlertView()<UIAlertViewDelegate>

@end

@implementation TCMAlertView{
    NSMutableArray<UIAlertAction *> *_actions;
}

/**
 * 为AlertView添加Action数据
 *
 *  · 会同时添加Action Title到Alert视图
 * @param action TCMAlertAction实例对象
 */
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message{
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.delegate = self;
    }
    return self;
}


/**
 * 为AlertView添加Action数据
 *
 *  · 会同时添加Action Title到Alert视图
 * @param action TCMAlertAction实例对象
 */
- (void)addAction:(TCMAlertAction *)action{
    if (!_actions) {
        _actions = [NSMutableArray array];
    }
    [self addButtonWithTitle:action.title];
    [_actions addObject:[action copy]];
}

/**
 * 获取已经添加到Alert的Action数据
 */
- (NSArray<UIAlertAction *> *)actions{
    return [_actions copy];
}

/**
 * 点击Action的回调协议方法
 *
 * @param alertView alertView
 * @param buttonIndex 点击的Action索引
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //进行数据安全检测
    if (buttonIndex > _actions.count) {
        return;
    }
    UIAlertAction *action = [_actions objectAtIndex:buttonIndex];

    if ([action respondsToSelector:@selector(action)]) {
        [action performSelector:@selector(action)];
    }
}

@end
