//
//  thybridBackgroundView.h
//  AFNetworking
//
//  Created by Dao on 2018/11/17.
//

#import <UIKit/UIKit.h>
#import "tHybridWeexProtocol.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger THYBRID_BACKGROUND_VIEW_TAG;

extern const NSInteger THYBRID_CREATE_VIEW_TAG;


typedef NS_ENUM(NSUInteger, THYBRID_LOADING_STATUS) {
    /** 加载中 */
    THYBRID_LOADING_STATUS_LOADING,
    /** 网络异常 */
    THYBRID_LOADING_STATUS_NETWORK_ERROR,
    /** 加载失败 */
    THYBRID_LOADING_STATUS_LOAD_FAILED,
    /** 文件不存在 */
    THYBRID_LOADING_STATUS_NO_FILE,
    /** 加载完成 */
    THYBRID_LOADING_STATUS_LOAD_FINISH,
    /** 文件解析失败 */
    THYBRID_LOADING_STATUS_FILE_EXECUTION_FAILED,
    /** 渲染完成 */
    THYBRID_LOADING_STATUS_RENDER_FINISH,
};

@interface thybridBackgroundView : UIView

@property (nonatomic, weak) UIViewController<tHybridWeexProtocol> *handler;

@property (nonatomic, weak) UINavigationBar *navigationBar;
@property (nonatomic, weak) UINavigationItem *navigationItem;


@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic,strong) UIBarButtonItem *leftBarButtonItem;
@property (nullable, nonatomic,strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, assign) THYBRID_LOADING_STATUS loadingStatus;

+ (instancetype)objectWithHandler:(UIViewController<tHybridWeexProtocol> *)handler;

@end

NS_ASSUME_NONNULL_END
