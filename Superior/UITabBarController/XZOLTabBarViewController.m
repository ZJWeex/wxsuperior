//
//  XZOLTabBarViewController.m
//  Knowledge
//
//  Created by Dao on 2018/7/14.
//  Copyright © 2018  XueZhiOnline . All rights reserved.
//

#import "XZOLTabBarViewController.h"
#import "WXStorageModule.h"


@interface XZOLTabBarViewController () <UIGestureRecognizerDelegate, UITabBarControllerDelegate>

@property (nonatomic, copy) NSArray *urlList;
@property (nonatomic, copy) NSArray *titleList;
@property (nonatomic,strong)WXStorageModule *storage;
@end

@implementation XZOLTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.delegate = self;
    self.storage = [WXStorageModule new];
    // Do any additional setup after loading the view.

    for (UIViewController *controller in self.viewControllers) {
        [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.redColor} forState:UIControlStateSelected];
        //正常图片 渲染模式
        controller.tabBarItem.image = [controller.tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //点击图片
        controller.tabBarItem.selectedImage = [controller.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    _urlList = @[
                 @"base-superior/homepage_index.js",
                 @"base-superior/brandstory_index.js",
                 @"base-superior/shopping_index.js",
                 @"base-superior/personal_index.js",
                 ];

    _titleList = @[
                   @"优先商城",
                   @"品牌故事",
                   @"购物车",
                   @"",
                   ];

    thybridViewController *controller = self.viewControllers.firstObject;
    controller.weexUrl = [NSURL weexUrlWithFilePath:self.urlList.firstObject];
    controller.navigationItem.title = self.titleList.firstObject;
    [controller resetNavigationBar];
    NSLog(@"%@", controller.weexUrl);
    [controller renderWeex];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"changeBadge" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTabbar:) name:@"changeTabbar" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self changeBadge];
}
-(void)changeBadge {
    __weak typeof(self) weakSelf = self;
    [self.storage getItem:@"LocalStorage_CartData" callback:^(NSDictionary *result) {
        NSLog(@"get:%@",result);
        int count = 0;
        NSData *jsonData = [result[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"json=%@",json);
        if ([json isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray*)json;
            for (NSDictionary *group in array) {
                id supGoodsList = group[@"supGoodsList"];
                if ([supGoodsList isKindOfClass:[NSArray class]]) {
                    NSArray *supGoodsArray = (NSArray*)supGoodsList;
                    for (NSDictionary *item in supGoodsArray) {
                        count += [item[@"count"] intValue];
                    }
                }
            }
        }
        if (count >0) {
            UIViewController *vc = weakSelf.viewControllers[2];
            vc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",count];
        }else{
            UIViewController *vc = weakSelf.viewControllers[2];
            vc.tabBarItem.badgeValue = nil;
        }
        
    }];
}
-(void)changeTabbar:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger selectIndex = [userInfo[@"param"] integerValue];
    if (selectIndex < self.viewControllers.count) {
        [self setSelectedIndex:selectIndex];
    }
    
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(thybridViewController *)viewController{
    if (!viewController.weexUrl) {
        viewController.weexUrl = [NSURL weexUrlWithFilePath: [self.urlList objectAtIndex:[self.viewControllers indexOfObject:viewController]]];
        viewController.navigationItem.title = [self.titleList objectAtIndex:[self.viewControllers indexOfObject:viewController]];
        [viewController resetNavigationBar];
        [viewController renderWeex];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}



+ (NSString *)nameOfStoryboard{
    return @"Main";
}

@end
