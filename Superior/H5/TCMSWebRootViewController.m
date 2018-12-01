 //
//  TCMSWebRootViewController.m
//  Superior
//
//  Created by Dao on 2018/7/13.
//  Copyright © 2018 淘菜猫. All rights reserved.
//

#import "TCMSWebRootViewController.h"
#import <QuartzCore/CATransform3D.h>
#import "GDPaymentSystem.h"

#import "TCMAppKeyManager.h"
#import "SocialShareUI.h"
#import <WebKit/WKWebView.h>

#import <TCMNetWorking.h>

#import "UIWebView+TS_JavaScriptContext.h"

@interface TCMSWebRootViewController ()<TSWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *promptView;


@property(nonatomic, weak) IBOutlet UIWebView *contentWeb;
@property(nonatomic, assign) BOOL canback;
@property(nonatomic, assign) BOOL currentStatus;

@property (nonatomic, copy) NSString *session;

@property (nonatomic, assign) BOOL Cookie;


@property (nonatomic, copy) NSURL *url;

@property (nonatomic, copy) NSURLRequest *urlRequest;

@property (nonatomic, copy) NSDictionary *shareData;
@end

@implementation TCMSWebRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"淘菜猫优选商城";


//    [self loadRequestURL:@"http://192.168.15.238:8081/dist/superiorShopDev/index.html" web:self.contentWeb];
//        [self loadRequestURL:@"http://192.168.15.101:8080/mine.html" web:self.contentWeb];


        NSString *url = [NSString stringWithFormat:@"%@/superior/wechat/app.htm", [TCMNetWorking baseURLString]];
        [self loadRequestURL:url web:self.contentWeb];


//    [self addImageBarButtonItem:@"supermarkets_fh" action:@selector(leftBarButtonAction) rightSide:NO merge:NO];
//    [self addImageBarButtonItem:@"share_fenxiang" action:@selector(rightBarButtonAction) rightSide:YES merge:NO];

    self.currentStatus = YES;
    [self leftItem];
    self.contentWeb.scrollView.bounces = NO;
    self.contentWeb.scrollView.showsVerticalScrollIndicator = NO;

    self.navigationItem.rightBarButtonItem.customView.hidden = YES;

    [TCMNetWorking setSessionID:self.session];
}


- (void)leftBarButtonAction{
    if (self.webInstance.webView.canGoBack) {
        [self.webInstance.webView goBack];
    }
}

- (void)rightBarButtonAction{
    [self SocialShare:self.shareData];
}

- (IBAction)refreshWebView:(id)sender {
    [self.contentWeb loadRequest:self.urlRequest];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    self.urlRequest = request.copy;
    self.shareData = nil;
    BOOL load = [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    [self loadWebModule:webView];

    NSLog(@"sessionId%@", [webView stringByEvaluatingJavaScriptFromString:@"localStorage.getItem('sessionId')"]);

    if ([request.URL.path containsString:@"/taocaimall/superior/wechat/"]) {
        if ([request.URL.path isEqualToString:@"/taocaimall/superior/wechat/app.htm"] || [request.URL.path isEqualToString:@"/taocaimall/superior/wechat/index.htm"]) {
            self.canback = NO;
        } else if ( [request.URL.path isEqualToString:@"/taocaimall/superior/wechat/page.htm"]) {
            NSDictionary *data = request.URL.tcmRequestData;
            NSString *pageName = data[@"pageName"];
            if ([pageName isEqualToString:@"shoppingCart"]
                || [pageName isEqualToString:@"mine"]
                || [pageName isEqualToString:@"brandStory"]
                || [pageName isEqualToString:@"index"]) {
                self.canback = NO;
            } else {
                self.canback = YES;
            }
        }
    } else {
        if ([request.URL.path containsString:@"/shoppingCart."]
            || [request.URL.path containsString:@"/mine."]
            || [request.URL.path containsString:@"/brandStory."]
            || [request.URL.path containsString:@"/index."]) {
            self.canback = NO;
        } else {
            self.canback = YES;
        }
    }
    [self leftItem];

    return load;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [UIView animateWithDuration:.3 animations:^{
        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    }];
    self.promptView.hidden = YES;
}
- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx{
    [self loadWebModule:webView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *headerStr = @"document.title";
    self.title = [webView stringByEvaluatingJavaScriptFromString:headerStr];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.promptView.hidden = NO;
}

- (void)loadWebModule:(UIWebView *)webView{
    [super loadWebModule:webView];
    NSMutableDictionary *Payment = [NSMutableDictionary dictionary];
    Payment[@"WeChat"] = ^(JSValue *msg){
        NSString *jsonData = [msg toObject];
        NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        [self performSelectorOnMainThread:@selector(Payment:) withObject:[dic copy] waitUntilDone:NO];
    };

    NSMutableDictionary *SocialShare = [NSMutableDictionary dictionary];
    SocialShare[@"Share"] = ^(JSValue *msg){
        NSString *jsonData = [msg toObject];
        NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        [self performSelectorOnMainThread:@selector(setShareData:) withObject:[dic copy] waitUntilDone:NO];
    };

    JSContext *context  = [self.contentWeb valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"Payment"] = Payment;
    context[@"SocialShare"] = SocialShare;
    context[@"log"] = ^(JSValue *msg){
        NSDictionary *dic = [msg toObject];
        [self performSelectorOnMainThread:@selector(setShareData:) withObject:[dic copy] waitUntilDone:NO];
    };
}
- (void)leftItem{
    if (self.currentStatus == self.canback) {
        return;
    }
    self.currentStatus = self.canback;
    if (self.canback) {
        self.navigationItem.leftBarButtonItem.customView.hidden = NO;
    } else {
        self.navigationItem.leftBarButtonItem.customView.hidden = YES;
    }
}


- (void)Payment:(NSDictionary *)paymentData{
    NSArray *orderIds = [paymentData valueForKey:@"orderid"];
    __block NSString *notify_url = [paymentData valueForKey:@"notify_url"];
    NSLog(@"淘菜猫优先商城支付启动:");
    //    NSLog(@"淘菜猫优先商城支付启动:%@", orderId);
    GDPaymentTypeModel *model = [[GDPaymentTypeModel alloc] init];
    model.paymentType = GDPaymentTypeWechat;
    model.paymentTypeStr = @"weChatpay";


    NSLog(@"%@", [self.webInstance.webView stringByEvaluatingJavaScriptFromString:@"localStorage.getItem('sessionId')"]);
    [TCMNetWorking setSessionID:[self.webInstance.webView stringByEvaluatingJavaScriptFromString:@"localStorage.getItem('sessionId')"]];

    __weak typeof(self) weakSelf = self;
    [GDPaymentSystem payWithTyep:model orderID:[orderIds componentsJoinedByString:@","] getURLFailed:^(NSError *error) {
        [CESHelper showPromptHUBWithMsg:error.domain];
        [weakSelf afterPay:notify_url];
    } paymentSuccessed:^(NSString *obj) {
        [weakSelf afterPay:notify_url];
    } paymentFailed:^(NSString *obj) {// 支付失败
        [CESHelper showPromptHUBWithMsg:obj];
        [weakSelf afterPay:notify_url];
    } afterPay:^{
        [weakSelf afterPay:notify_url];
    } handle:self isSuperior:YES];

}

- (void)afterPay:(NSString *)notify_url{
    if (notify_url.length) {
        NSString *url = self.contentWeb.request.URL.absoluteString;
        NSString *pageName = self.contentWeb.request.URL.tcmRequestData[@"pageName"];
        if (pageName.length) {
            NSString *path = [url componentsSeparatedByString:@"?"].firstObject;
            url = [NSString stringWithFormat:@"%@?%@", path, notify_url];
            if ([url containsString:@"pageName=orderdetail"]) {
                NSString *string = [NSString stringWithFormat:@"window.location.replace('%@');",url];
                [self.contentWeb stringByEvaluatingJavaScriptFromString:string];
            } else {
                [self.contentWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
            }
        }
    } else {
        [self.contentWeb reload];
    }
}


- (void)SocialShare:(NSDictionary *)shareData{
    //    SocialShareUI.message = [SocialShareMessage appMessage:@"从你的全世界路过"
    //                                               description:@"我希望有个如你一般的人，如山间清爽的风，如古城温暖的光。从清晨到夜晚，由山野到书房。只要最后是你，就好..."
    //                                                thumbImage:[UIImage imageNamed:@"icon_85"]
    //                                                  storeURL:@"https://itunes.apple.com/cn/app/id1299652173?mt=8"
    //                                                  platform:SocialShareMessage_Unknow];


    NSString *msg = shareData[@"message"];
    NSString *des = shareData[@"description"];

    NSURL *imgUrl = [NSURL URLWithString:shareData[@"thumbImage"]];
    NSData *imgData = [NSData dataWithContentsOfURL: imgUrl];
    UIImage *image = [UIImage imageWithData: imgData];
    NSString *webUrl = shareData[@"webURL"];
    webUrl = [webUrl stringByReplacingOccurrencesOfString:@"&stateKey=fromAppWeChat_state_" withString:@""];
    webUrl = [webUrl stringByReplacingOccurrencesOfString:@"app.htm" withString:@"page.htm?pageName=index"];

    SocialShareUI.message = [SocialShareMessage webMessage: msg
                                               description: des
                                                thumbImage: image
                                                    webURL: webUrl
                                                  platform:SocialShareMessage_Unknow];

    //        SocialShareUI.message = [SocialShareMessage textMessage:@"我希望有个如你一般的人，如山间清爽的风，如古城温暖的光。从清晨到夜晚，由山野到书房。只要最后是你，就好..."
    //                                                       platform:SocialShareMessage_Unknow];

    //    SocialShareUI.message = [SocialShareMessage musicMessage:@"从你的全世界路过"
    //                                                 description:@"我希望有个如你一般的人，如山间清爽的风，如古城温暖的光。从清晨到夜晚，由山野到书房。只要最后是你，就好..."
    //                                                  thumbImage:[UIImage imageNamed:@"icon_46"]
    //                                                    musicURL:@"https://music.163.com/#/album?id=34897385"
    //                                                    platform:SocialShareMessage_Unknow];
    //    SocialShareUI.message.respondBlock = ^(SocialShareResp *resp) {
    //        [CESHelper showPromptHUBWithMsg:[NSString stringWithFormat:@"%ld:%@", resp.result, resp.msg]];
    //    };

    //    SocialShareUI.message = [SocialShareMessage imageMessage:[UIImage imageNamed:@"icon_96"]
    //                                                    platform:SocialShareMessage_Unknow];


    //    SocialShareUI.message = [SocialShareMessage videoMessage:@"从你的全世界路过"
    //                                                 description:@"我希望有个如你一般的人，如山间清爽的风，如古城温暖的光。从清晨到夜晚，由山野到书房。只要最后是你，就好..."
    //                                                  thumbImage:[UIImage imageNamed:@"icon_71"]
    //                                                    videoURL:@"https://music.163.com/#/mv?id=5843407"
    //                                                    platform:SocialShareMessage_Unknow];

    //    SocialShareUI.message = [SocialShareMessage authMessage];

    [SocialShareUI showShareMenuInWindowWithPlatformArray:@[
                                                            @(SocialSharePlatform_WeChat_Session),
                                                            @(SocialSharePlatform_WeChat_Timeline),
//                                                            @(SocialSharePlatform_QQ_Zone),
//                                                            @(SocialSharePlatform_QQ_Session)
                                                            ]
                                           selectionBlock:^(SocialSharePlatform platform, NSDictionary *userInfo) {
                                               [CESHelper showPromptHUBWithMsg:@(platform).stringValue];
                                           }];
}

- (void)setShareData:(NSDictionary *)shareData{
    _shareData = [shareData copy];
    if (!_shareData) {
        [UIView animateWithDuration:.3 animations:^{
            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
        }];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            self.navigationItem.rightBarButtonItem.customView.hidden = NO;
        }];
    }

}
@end
