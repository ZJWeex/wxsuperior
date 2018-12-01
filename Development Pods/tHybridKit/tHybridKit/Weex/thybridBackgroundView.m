//
//  thybridBackgroundView.m
//  AFNetworking
//
//  Created by Dao on 2018/11/17.
//

#import "thybridBackgroundView.h"
#import "TCMWeex.h"
#import <Masonry/Masonry.h>


const NSInteger THYBRID_BACKGROUND_VIEW_TAG = 1024;
const NSInteger THYBRID_CREATE_VIEW_TAG = 2048;

@interface thybridBackgroundView ()

@property (nonatomic, strong) UIView *NavigationView;

@property (nonatomic, strong) UIView *optionView;

@end

@implementation thybridBackgroundView


- (instancetype)init{
    self = [super init];
    UIView *containView = [[UIView alloc] init];
    
    [self addSubview:containView];
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.offset(0);
    }];
    
    [self navigationItem];

    return self;
}


- (void)setLoadingStatus:(THYBRID_LOADING_STATUS)loadingStatus{
    _loadingStatus = loadingStatus;

    switch (loadingStatus) {
        case THYBRID_LOADING_STATUS_LOADING:
            [self resetOptionView:nil];
            break;
        case THYBRID_LOADING_STATUS_NETWORK_ERROR:
            [self networkError];
            break;
        case THYBRID_LOADING_STATUS_LOAD_FAILED:
            [self loadFail];
            break;
        case THYBRID_LOADING_STATUS_LOAD_FINISH:
            self.exclusiveTouch = NO;
            break;
        case THYBRID_LOADING_STATUS_FILE_EXECUTION_FAILED:
            [self executionFail];
            break;
        case THYBRID_LOADING_STATUS_RENDER_FINISH:
//            [self finish];
            break;
    }
}

- (void)networkError{
    UIButton *button = [[UIButton alloc] init];

    [self resetOptionView:button];
    [button setTitle:@"网络不可用,请检查网络后重试！" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(action) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)loadFail{
    UIButton *button = [[UIButton alloc] init];

    [self resetOptionView:button];
    [button setTitle:@"链接服务器失败,点击屏幕后重新加载！" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(action) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)executionFail{
    UIButton *button = [[UIButton alloc] init];

    [self resetOptionView:button];
    [button setTitle:@"程序异常,请稍后重试！" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(action) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)finish{
    [self resetOptionView:nil];
    self.hidden = YES;
}


- (void)action{
    [self resetOptionView:nil];
    if ([self.handler respondsToSelector:@selector(rendererWeex)]) {
        [self.handler rendererWeex];
    }
}

- (UINavigationBar *)navigationBar{
    if (!_navigationBar) {
        UIView *NavigationView = [[UIView alloc] init];
        [self addSubview:NavigationView];
        [NavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.offset(0);
            if (tHybridKit.Thybrid_Kit_Iphone_X){
                make.height.mas_equalTo(44 + 44);
            } else {
                make.height.mas_equalTo(44 + 20);
            }
        }];
        _NavigationView = NavigationView;
        
        UINavigationBar *bar = [[UINavigationBar alloc] init];
        bar.barTintColor = NavigationView.backgroundColor = [UIColor colorWithRed:0.0 green:129.0/255.0 blue:240/255.0 alpha:1.0];
        bar.translucent = NO;
        
        [NavigationView addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.offset(0);
        }];
        
        _navigationBar = bar;
    }
    
    return _navigationBar;
}

- (UINavigationItem *)navigationItem{
    if (!_navigationItem) {
        UINavigationItem *item = [[UINavigationItem alloc] init];
        self.navigationBar.items = @[item];
        item.title = @"优选";
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                     }];
        
        _navigationItem = item;
    }
    
    return _navigationItem;
}


- (NSString *)title{
    return self.navigationItem.title;
}
- (void)setTitle:(NSString *)title{
    if (!title.length) {
        self.NavigationView.backgroundColor = [UIColor whiteColor];
        self.navigationBar.hidden = YES;

        [self.NavigationView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];

        return;
    }
    self.navigationItem.title = title;
}
- (UIBarButtonItem *)leftBarButtonItem{
    return self.navigationItem.leftBarButtonItem;
}
- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem{
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (UIBarButtonItem *)rightBarButtonItem{
    return self.navigationItem.rightBarButtonItem;
}
- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
- (void)resetOptionView:(UIView *)childView{
    [self.optionView removeFromSuperview];

    if (!childView) {
        return;
    }
    UIView *view = [[UIView alloc] init];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.top.mas_equalTo(self.NavigationView.mas_bottom).offset(0);
    }];

    childView.backgroundColor = UIColor.grayColor;
    [view addSubview:childView];
    [childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.top.offset(0);
    }];
    self.optionView = view;
}

@end
