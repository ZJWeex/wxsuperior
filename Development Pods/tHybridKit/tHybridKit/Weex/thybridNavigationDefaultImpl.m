//
//  thybridNavigationDefaultImpl.m
//  AFNetworking
//
//  Created by Dao on 2018/10/25.
//

#import "thybridNavigationDefaultImpl.h"
#import "UIViewController+tHybridWeex.h"


@implementation thybridNavigationDefaultImpl

- (void)pushViewControllerWithParam:(NSDictionary *)param completion:(WXNavigationResultBlock)block
                      withContainer:(UIViewController *)container
{
    if (0 == [param count] || !param[@"url"] || !container) {
        [super pushViewControllerWithParam:param completion:block withContainer:container];
        return;
    }


    [container springWithURL:param[@"url"] option:param];
}

- (void)popViewControllerWithParam:(NSDictionary *)param completion:(WXNavigationResultBlock)block
                     withContainer:(UIViewController *)container
{
    if (0 == [param count]) {
        [super popViewControllerWithParam:param completion:block withContainer:container];
        return;
    }
    [container pop:param];
}

@end
