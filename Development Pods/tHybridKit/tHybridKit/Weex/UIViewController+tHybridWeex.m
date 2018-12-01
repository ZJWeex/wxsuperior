//
//  UIViewController+Weex.m
//  Weex
//
//  Created by Dao on 2018/1/18.
//  Copyright © 2018年 Taocaimall. All rights reserved.
//

#import "UIViewController+tHybridWeex.h"

#import "NSURL+tHybrid.h"
#import <objc/runtime.h>
#import "Masonry.h"

#import "tHybridKitModule.h"

#import <WXSDKManager.h>

#import "thybridBackgroundView.h"


@interface thybridViewController()

@property (nonatomic, strong) thybridBackgroundView *privateContentView;

@property (nonatomic, strong) UIView *createView;

@end


@implementation thybridViewController
@synthesize weexInstance;
@synthesize weexView;
@synthesize weexUrl;
@synthesize options;
@synthesize contentView;
@synthesize renderOption;

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.weexUrl) {
        [self renderWeex];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self rendererWeex];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.renderOption == thybridRenderOptionOnFail) {
        [self renderOption];
    }
    [self.weexInstance fireGlobalEvent:@"viewappear" params:nil];
    [[WXSDKManager bridgeMgr] fireEvent:self.weexInstance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[WXSDKManager bridgeMgr] fireEvent:self.weexInstance.instanceId ref:WX_SDK_ROOT_REF type:@"viewdisappear" params:nil domChanges:nil];
}

- (void)renderFinish:(UIView *)view{
    if (self.options) {
        [self refreshWeexInstance];
    }
    //加载完成
    self.privateContentView.loadingStatus = THYBRID_LOADING_STATUS_RENDER_FINISH;
    NSLog(@"renderOption:%ld", self.renderOption);
}
- (void)onJSRuntimeException:(WXJSExceptionInfo *)jsException{
    if (jsException.errorCode.integerValue == -2013) {
        self.privateContentView.loadingStatus = THYBRID_LOADING_STATUS_FILE_EXECUTION_FAILED;
        [self.createView removeFromSuperview];
    }
    NSLog(@"renderOption:%ld", self.renderOption);
}
- (void)onFailed:(NSError *)error{
    if (error.code == -2205) {
        self.privateContentView.loadingStatus = THYBRID_LOADING_STATUS_NETWORK_ERROR;
    } else if(error.code == -2202){
        self.privateContentView.loadingStatus = THYBRID_LOADING_STATUS_LOAD_FAILED;
    }
}

- (void)onCreate:(UIView *)view{
    if (self.contentView) {
        [self.contentView removeAllSubview];
        [self.contentView addSubview:view];
    } else {
        [self.view addSubview:view];
    }

    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [view.superview layoutSubviews];
    self.weexInstance.frame = view.frame;
    self.createView = view;
    self.privateContentView.loadingStatus = THYBRID_LOADING_STATUS_LOAD_FINISH;
}

- (void)resetNavigationBar{
    self.privateContentView.title = self.navigationItem.title;
}


- (thybridBackgroundView *)privateContentView{
    if (!_privateContentView) {
        thybridBackgroundView *backgroundView = [[thybridBackgroundView alloc] init];
        backgroundView.tag = THYBRID_BACKGROUND_VIEW_TAG;

        [self.view addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_offset(0);
        }];

        if (!self.tabBarController) {
            UIImage *image = [[UIImage imageNamed:@"supermarkets_fh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:(UIBarButtonItemStylePlain) target:self action:@selector(pop:)];
            backgroundView.navigationItem.leftBarButtonItem = item;
        }

        /*
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarButtonAction)];
        backgroundView.navigationItem.rightBarButtonItem = item;
         */

        backgroundView.handler = self;
        _privateContentView = backgroundView;
    }

    return _privateContentView;
}

- (void)rightBarButtonAction{
    [self renderWeex];
}


@end


@interface UIViewController ()<tHybridWeexProtocol,UIGestureRecognizerDelegate>

@property (nonatomic, weak, readonly) thybridBackgroundView *privateContentView;


@end

@implementation UIViewController (tHybridWeex)

- (void)renderWeexWithURL:(NSURL *)url{
    self.weexUrl = url;
    [self renderWeex];
}
- (void)renderWeex{
    [self renderWeexWithOptions:self.options];
}
- (void)rendererWeex{
    NSLog(@"renderOption:%ld-renderOption:%ld", thybridRenderOptionOnFail, thybridRenderOptionExecutionFail);
    if (self.renderOption & thybridRenderOptionOnFail ||
        self.renderOption & thybridRenderOptionExecutionFail){
        [self renderWeex];
    }
}


- (void)renderWeexWithOptions:(NSObject *)options{
    [self.weexInstance destroyInstance];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.weexInstance = [[WXSDKInstance alloc] init];
    self.weexInstance.viewController = self;
    if (self.contentView) {
        CGRect frame = self.contentView.frame;
        frame.origin = CGPointZero;
        self.weexInstance.frame = frame;
    } else {
        self.weexInstance.frame = self.view.frame;
    }

    self.renderOption = thybridRenderOptionOnRendering;
    self.privateContentView.loadingStatus = THYBRID_LOADING_STATUS_LOADING;
    __weak typeof(self) weakSelf = self;
    self.weexInstance.onCreate = ^(UIView *view) {
        weakSelf.renderOption |= thybridRenderOptionOnCreate;

        //进行安全校验，避免出现运行时Crash现象
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf onCreate:view];
        [[WXSDKManager bridgeMgr] fireEvent:weakSelf.weexInstance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];

    };
    self.weexInstance.onFailed = ^(NSError *error) {
        //process failure
        weakSelf.renderOption |= thybridRenderOptionOnFail;
        [weakSelf performSelectorOnMainThread:@selector(onFailed:) withObject:error waitUntilDone:NO];
    };

    self.weexInstance.renderFinish = ^ (UIView *view) {
        //process renderFinish
        weakSelf.renderOption |= thybridRenderOptionOnFinish;
        [weakSelf performSelectorOnMainThread:@selector(renderFinish:) withObject:view waitUntilDone:NO];
    };

    self.weexInstance.onRenderProgress = ^ (CGRect renderRect) {
    };
    self.weexInstance.onJSDownloadedFinish = ^(WXResourceResponse *response, WXResourceRequest *request, NSData *data, NSError *error) {
    };
    self.weexInstance.onJSRuntimeException = ^(WXJSExceptionInfo *jsException) {
        weakSelf.renderOption |= thybridRenderOptionExecutionFail;

        [weakSelf performSelectorOnMainThread:@selector(onJSRuntimeException:) withObject:jsException waitUntilDone:NO];
    };

    NSMutableDictionary *GlobalEvent = [NSMutableDictionary dictionary];
    [GlobalEvent setValue:tHybridKitModule.GlobalEventRefreshInstance forKey:@"GlobalEventRefreshInstance"];

    [self.weexInstance renderWithURL:self.weexUrl options:@{@"GlobalEvent":GlobalEvent, @"title": self.title?:@""} data:nil];
    self.options = options;
}

- (void)refreshWeexInstance{
    [self.weexInstance fireGlobalEvent:tHybridKitModule.GlobalEventRefreshInstance params:self.options];
}




/**
 <#Description#>

 @param url <#url description#>
 @param option <#option description#>
 */
- (void)springWithURL:(NSString *)url option:(NSDictionary *)option{
    if (!url.length) {
        return ;
    }

    //仅支持.js文件
    url = [url stringByReplacingOccurrencesOfString:@".html" withString:@".js"];

    //过滤正常URL
    if (![url hasPrefix:@"http"]) {
        NSString *preURL = @"";
        //过滤非绝对路径[WEEX以‘/’开始为绝对路径]
        if (![url hasPrefix:@"/"]) {

            //获取基地址
            static NSString *baseURL = nil;
            if (!baseURL) {
                baseURL = [NSURL weexUrlWithFilePath:@""].absoluteString;
            }
            NSString *currentURLStr = self.weexUrl.absoluteString;
            currentURLStr = [currentURLStr stringByReplacingOccurrencesOfString:baseURL withString:@""];
            NSRange range = [currentURLStr rangeOfString:@"/" options:(NSBackwardsSearch)];

            //获取当前目录
            NSString *currentPath = nil;
            if (range.location) {
                currentPath = [currentURLStr substringWithRange:NSMakeRange(0, range.location+1)];
            }

            //逐级目录返回
            NSRange tagRange = NSMakeRange(0, url.length);
            do {
                tagRange = [url rangeOfString:@"../" options:(NSCaseInsensitiveSearch) range:NSMakeRange(0, url.length)];
                if (tagRange.length) {

                    NSRange range = [currentPath rangeOfString:@"/" options:(NSBackwardsSearch) range:NSMakeRange(0, currentPath.length-1)];
                    currentPath = [currentURLStr substringWithRange:NSMakeRange(0, range.location+1)];

                    url = [url substringFromIndex:tagRange.length];

                    NSLog(@"WEEX_URL:%@%@", currentPath, url);
                }
            } while (tagRange.length);
            preURL = currentPath;
        }
        url = [NSString stringWithFormat:@"%@%@", preURL, url];
        NSLog(@"%@", url);
        NSLog(@"%@", url);
    }

    [self performBlock:^{
        UIViewController *VC = [[thybridViewController alloc] init];
        VC.view.backgroundColor = [UIColor whiteColor];
        VC.weexUrl = [NSURL weexUrlWithFilePath:url];
        VC.title = [option valueForKey:@"title"] ? : @"";
        [VC resetNavigationBar];

        [VC renderWeexWithOptions:option];

        UIViewController *contain = self;
        NSString *switchTab = [option valueForKey:@"switchTab"];
        if (switchTab) {
            NSUInteger index = switchTab.integerValue;
            UITabBarController *tabBarViewController = self.tabBarController;
            if (index >= 0 && index < tabBarViewController.viewControllers.count) {
                contain = [tabBarViewController.viewControllers objectAtIndex:index];
                [tabBarViewController setSelectedIndex:index];
            }
        }
        
        if ([contain isKindOfClass:UINavigationController.class]) {
            ((UINavigationController *)contain).interactivePopGestureRecognizer.delegate = self;
            [(UINavigationController *)contain pushViewController:VC animated:YES];
        } else {
            self.navigationController.interactivePopGestureRecognizer.delegate = self;
            [contain.navigationController pushViewController:VC animated:YES];
        }
    }];
}

- (void)pop:(NSDictionary *)option{
    [self performBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)performBlock:(void(^)(void))blocks{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        blocks();
    }];
}


- (void)resetNavigationBar{

}

- (void)renderFinish:(UIView *)view{

}
- (void)onJSRuntimeException:(WXJSExceptionInfo *)jsException{

}
- (void)onFailed:(NSError *)error{

}

- (void)onCreate:(UIView *)view{

}

@end
