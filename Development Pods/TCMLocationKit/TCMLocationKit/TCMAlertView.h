//
//  TCMAlertView.h
//  Pods
//
//  Created by Dao on 2018/1/10.
//

#import <UIKit/UIKit.h>
#import "TCMAlertAction.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *  基于UIAlertView的Alert控件
 *
 *  ·在调用Show展示Alert时，会进行进一步的初始化操作
 */
@interface TCMAlertView : UIAlertView


/**
 * 初始化一个实例对象
 *
 *  · 无Button相关，Button通过TCMAlertAction实现
 * @param title 用于Alert的Title信息
 * @param message 用于Alert的Msg信息
 * @return return 实例对象[仅进行了数据保存]
 */
- (instancetype _Nullable )initWithTitle:(nullable NSString *)title
                                 message:(nullable NSString *)message;


/**
 * 为AlertView添加Action数据
 *
 *  · 会同时添加Action Title到Alert视图
 * @param action TCMAlertAction实例对象
 */
- (void)addAction:(TCMAlertAction *_Nonnull)action;


/**
 * 获取已经添加到Alert的Action数据
 */
@property (nonatomic, readonly) NSArray<UIAlertAction *> *actions;

@end

NS_ASSUME_NONNULL_END
