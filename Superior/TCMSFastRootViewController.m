//
//  TCMSFastRootViewController.m
//  Superior
//
//  Created by Dao on 2018/8/6.
//  Copyright © 2018 淘菜猫. All rights reserved.
//

#import "TCMSFastRootViewController.h"

#import "NSObject+tHybridURL.h"

#define IPHONE_SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width                   //屏幕宽度
#define IPHONE_SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height                  //屏幕高度
#define IPHONE_SCREEN_SIZE     [[UIScreen mainScreen] bounds].size                         //屏幕尺寸
#define IPHONE_SCREEN_SCALE    (IPHONE_SCREEN_WIDTH / IPHONE_DESIGN_WIDTH)


/**5, 5S, 5SE等*/
#define IPHONE                  (IPHONE_SCREEN_WIDTH < IPHONE_DESIGN_WIDTH)
/**6、6S*/
#define IPHONE_DESIGN           (IPHONE_SCREEN_WIDTH == IPHONE_DESIGN_WIDTH)
/**6 Plus、6S Plus*/
#define IPHONE_PLUS             (IPHONE_SCREEN_WIDTH > IPHONE_DESIGN_WIDTH)
/** 是否是iPhone X 系列*/
#define IPHONE_X                ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((int)(([[UIScreen mainScreen] currentMode].size.height / [[UIScreen mainScreen] currentMode].size.width) * 100) == 216) : NO)
//#define IPHONE_X                (IPHONE_SCREEN_WIDTH == IPHONE_DESIGN_WIDTH && IPHONE_SCREEN_HEIGHT > IPHONE_DESIGN_HEIGHT)


@interface TCMSFastRootViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray<UIImage *> *fastrootImages;

@property (nonatomic, weak) UIPageControl *page;

@property (nonatomic, weak) UIButton *immediateButton;
@property (nonatomic, weak) UIButton *jumpButton;

@property (nonatomic, assign) BOOL animate;
@end

@implementation TCMSFastRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromClass(self.class)]) {
        NSMutableArray<UIImage *> *imgArr = [NSMutableArray array];
        for (NSInteger idx=0; idx<10; idx++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"fastroot_%ld", (long)idx]];
            if (image) {
                [imgArr addObject:image];
            } else {
                break;
            }
        }
        self.fastrootImages = imgArr;
        [self fastRoot];
        return;
    }
    [self springToRoot];

}

- (void)fastRoot{
    UIScrollView *scorll = [[UIScrollView alloc] init];
    scorll.backgroundColor = UIColor.brownColor;
    scorll.bounces = NO;
    scorll.showsHorizontalScrollIndicator = NO;

    scorll.delegate = self;
    [self.view addSubview:scorll];

    [scorll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];

    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);

    [self.fastrootImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [scorll addSubview:imageView];

        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.width.mas_equalTo(width);
            make.left.mas_equalTo(width*idx);
        }];
    }];
    scorll.contentSize = CGSizeMake(width * self.fastrootImages.count, 0);
    scorll.pagingEnabled = YES;

    UIPageControl *page = [[UIPageControl alloc] init];

    page.pageIndicatorTintColor = UIColor.grayColor;
    page.currentPageIndicatorTintColor = [UIColor colorWithRed:208.0f/255.0f green:0.0f/255.0f blue:86.0f/255.0f alpha:1.0f];

    page.currentPage = 0;
    page.numberOfPages = self.fastrootImages.count;
    page.userInteractionEnabled = NO;
    [self.view addSubview:page];
    [page mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
    self.page = page;



    //跳过标签
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"跳过" forState:(UIControlStateNormal)];
    [button setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
    button.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.35f];
    button.layer.cornerRadius = 10;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColor.clearColor.CGColor;
    button.contentEdgeInsets = UIEdgeInsetsMake(3, 19, 3, 19);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(26);
        make.right.mas_equalTo(-20);
    }];
    [button addTarget:self action:@selector(springToRoot) forControlEvents:(UIControlEventTouchUpInside)];
    self.jumpButton = button;

    //跳过标签
    UIButton *buttonIm = [[UIButton alloc] init];
    [buttonIm setTitle:@"立即体验" forState:(UIControlStateNormal)];
    [buttonIm setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
    buttonIm.backgroundColor = [UIColor colorWithRed:208.0f/255.0f green:0.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
    buttonIm.layer.cornerRadius = 8;
    buttonIm.layer.borderWidth = 2;
    buttonIm.layer.borderColor = UIColor.clearColor.CGColor;
    buttonIm.titleLabel.font = [UIFont systemFontOfSize:28];
    buttonIm.contentEdgeInsets = UIEdgeInsetsMake(11, 100, 11, 100);
    [self.view addSubview:buttonIm];
    [buttonIm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(page).mas_offset(0);
        make.centerY.mas_equalTo(page).mas_offset(-50);

    }];
    [buttonIm addTarget:self action:@selector(springToRoot) forControlEvents:(UIControlEventTouchUpInside)];
    self.immediateButton = buttonIm;
    self.immediateButton.alpha = 0.0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    NSInteger page = scrollView.contentOffset.x/width;
    if (page == self.page.currentPage) {
        return;
    }
    if (page == self.fastrootImages.count-1) {
        //即将进入首页
        [self performAction:self.immediateButton from:.0 to:1.0];
        [self performAction:self.jumpButton from:1.0 to:0.0];

        self.immediateButton.alpha = 1.0;

        self.animate = YES;
    } else if (self.animate) {
        [self performAction:self.immediateButton from:1.0 to:0.0];
        [self performAction:self.jumpButton from:.0 to:1.0];
        self.animate = NO;
    }
    self.page.currentPage = page;

}

- (void)performAction:(UIView *)view from:(CGFloat)from to:(CGFloat)to{
    CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"transform"];

    basicAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(from, from, 1.0)];
    CATransform3D tran = CATransform3DMakeScale(to, to, 1.0);
    basicAnim.toValue = [NSValue valueWithCATransform3D:tran];

    basicAnim.autoreverses = NO;
    basicAnim.repeatCount = 1;
    basicAnim.duration = .3f;

    [view.layer addAnimation:basicAnim forKey:nil];
    [view.layer setTransform:tran];

}

- (void)springToRoot{

//    CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
//
//    basicAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
//    CATransform3D tran = CATransform3DMakeScale(2.5, 2.5, 1.0);
//    basicAnim.toValue = [NSValue valueWithCATransform3D:tran];
//
//    basicAnim.autoreverses = NO;
//    basicAnim.repeatCount = 1;
//    basicAnim.duration = .3f;
//
//    [self.view.layer addAnimation:basicAnim forKey:nil];
//    [self.view.layer setTransform:tran];
//
//    self.view.userInteractionEnabled = NO;
//
//    [self performSelector:@selector(action) withObject:nil afterDelay:basicAnim.duration];

    //    __FILE__


    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NSStringFromClass(self.class)];
    [self action];
}


- (void)action{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];

    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
//    [self levitatedSphere];
}


- (void)levitatedSphere{

    UILabel *levitatedSphere = [[UILabel alloc] initWithFrame:CGRectMake(5, IPHONE_X ? 30 : 20, IPHONE_SCREEN_WIDTH -5, 14)];
    levitatedSphere.textColor = [UIColor grayColor];
    levitatedSphere.textAlignment = NSTextAlignmentLeft;
    levitatedSphere.text = [self tHybridRemoteBaseURL];
    [[UIApplication sharedApplication].keyWindow addSubview:levitatedSphere];

    UILabel *vlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, IPHONE_SCREEN_WIDTH -10, 12)];
    UILabel *tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, IPHONE_X ? 15 : 30, IPHONE_SCREEN_WIDTH -10, 12)];

    tlabel.textColor = vlabel.textColor = [UIColor grayColor];
    tlabel.font = vlabel.font = [UIFont systemFontOfSize:12.0];
    tlabel.textAlignment = vlabel.textAlignment = NSTextAlignmentRight;
    [vlabel addSubview:tlabel];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    NSString *app_buildV = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *app_buildT = [infoDictionary objectForKey:@"TCMBuildTime"];


    vlabel.text = [NSString stringWithFormat:@"BuildVersion：%@_%@", app_Version, app_buildV];
    tlabel.text = [NSString stringWithFormat:@"BuildTime：%@", app_buildT];

    [levitatedSphere addSubview:vlabel];

}
@end
