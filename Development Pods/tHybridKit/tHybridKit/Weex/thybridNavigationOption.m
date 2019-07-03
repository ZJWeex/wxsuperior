//
//  thybridNavigationOption.m
//  AFNetworking
//
//  Created by Dao on 2018/12/1.
//

#import "thybridNavigationOption.h"
#import "NSURL+tHybrid.h"


@interface thybridNavigationOption ()

@property (nonatomic, copy) NSString *jsurl;

@end

@implementation thybridNavigationOption

#pragma mark - RGB —> UIColor
#define UIColorFromRGB(rgbValue)       [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, a)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

UIColor *colorFromStr(NSString *cString){
    if ([cString hasPrefix:@"0x"] || [cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];

    unsigned int r,g,b;
    [[NSScanner scannerWithString:[cString substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
    [[NSScanner scannerWithString:[cString substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
    [[NSScanner scannerWithString:[cString substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (instancetype)objectWithKeyValues:(NSDictionary<NSString *, NSString *> *)ids{
    thybridNavigationOption *obj = [[self alloc] init];

    obj.pop = [ids valueForKey:@"pop"].boolValue;
    obj.popToRoot = [ids valueForKey:@"popToRoot"].boolValue;
    obj.replace = [ids valueForKey:@"replace"].boolValue;
    obj.title = [ids valueForKey:@"title"]?:@"";
    obj.jsurl = [ids valueForKey:@"url"];
    if ([ids valueForKey:@"animate"]) {
        obj.animated = [ids valueForKey:@"animate"].boolValue;
    } else {
        obj.animated = YES;
    }
    if ([ids valueForKey:@"switchTab"]) {
        obj.selectedIndex = [ids valueForKey:@"switchTab"].integerValue;
    } else {
        obj.selectedIndex = thybridNavigationOptionTabUnkonw;
    }
    obj.option = ids;

    if ([ids valueForKey:@"titleColor"]) {
        obj.titleColorHex = [ids valueForKey:@"titleColor"];
    }

    if ([ids valueForKey:@"barColor"]) {
        obj.barColorHex = [ids valueForKey:@"barColor"];
    }

    return obj;
}



static NSString *_TitleColorHex_ = nil;
static NSString *_BarColorHex_ = nil;

- (instancetype)init{
    if (self = [super init]) {
        self.animated = YES;
        self.selectedIndex = thybridNavigationOptionTabUnkonw;

        if (_BarColorHex_) {
            self.barColorHex = _BarColorHex_;
        } else {
            self.barColor = [UINavigationBar appearance].barTintColor;
        }
        if (_TitleColorHex_) {
            self.titleColorHex = _TitleColorHex_;
        } else {
            self.titleColor = [[UINavigationBar appearance].titleTextAttributes valueForKey:NSForegroundColorAttributeName];
        }
    }
    return self;
}
+ (void)setTitleColorHex:(NSString *)titleColorHex{
    _TitleColorHex_ = titleColorHex;
}
+ (void)setBarColorHex:(NSString *)barColorHex{
    _BarColorHex_ = barColorHex;
}

- (void)setTitleColorHex:(NSString *)titleColorHex{
    _titleColorHex = titleColorHex;

    _titleColor = colorFromStr(_titleColorHex);
}
- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;

    double r,g,b;
    [_titleColor getRed:&r green:&g blue:&b alpha:nil];
    r *= 255;
    g *= 255;
    b *= 255;
    _titleColorHex = [NSString stringWithFormat:@"#%02x%02x%02x", (unsigned)r, (unsigned)g, (unsigned)b];
}


- (void)setBarColorHex:(NSString *)barColorHex{
    _barColorHex = barColorHex;
    
    _barColor = colorFromStr(_barColorHex);
}
- (void)setBarColor:(UIColor *)barColor{
    _barColor = barColor;

    double r,g,b;
    [_barColor getRed:&r green:&g blue:&b alpha:nil];
    r *= 255;
    g *= 255;
    b *= 255;
    _barColorHex = [NSString stringWithFormat:@"#%02x%02x%02x", (unsigned)r, (unsigned)g, (unsigned)b];
}


- (void)setJsurl:(NSString *)jsurl{
    _jsurl = [jsurl stringByReplacingOccurrencesOfString:@".html" withString:@".js"];
    _javascriptUrl = _jsurl;
}

- (void)resetWithCurrentJSUrlString:(NSString *)url{
    if (!_javascriptUrl) {
        return;
    }
    //过滤正常URL
    NSString *preURL = [NSURL weexUrlWithFilePath:@""].absoluteString;
    NSString *relativePath = _jsurl;
    //过滤非绝对路径[WEEX以‘/’开始为绝对路径]
    if (![relativePath hasPrefix:@"/"]) {
        NSString *currentURLStr = url;

        if ([currentURLStr hasSuffix:@"/"]) {
            currentURLStr = [currentURLStr substringWithRange:NSMakeRange(0, currentURLStr.length-1)];
        }
        currentURLStr = [currentURLStr stringByReplacingOccurrencesOfString:preURL withString:@""];
        NSRange range = [currentURLStr rangeOfString:@"/" options:(NSBackwardsSearch)];

        //获取当前目录
        NSString *currentPath = nil;
        if (range.location) {
            currentPath = [currentURLStr substringWithRange:NSMakeRange(0, range.location+1)];
        }

        //逐级目录返回
        NSRange tagRange;
        if ([relativePath hasPrefix:@"../"]) {
            do {
                tagRange = [relativePath rangeOfString:@"../" options:(NSCaseInsensitiveSearch) range:NSMakeRange(0, relativePath.length)];
                if (tagRange.length) {

                    NSRange range = [currentPath rangeOfString:@"/" options:(NSBackwardsSearch) range:NSMakeRange(0, currentPath.length-1)];
                    if (range.length) {
                        currentPath = [currentURLStr substringWithRange:NSMakeRange(0, range.location+1)];
                    }
                    relativePath = [relativePath substringFromIndex:tagRange.length];

                }
            } while (tagRange.length);
            NSLog(@"WEEX_URL:%@%@", currentPath, relativePath);
        } else {
            relativePath = [relativePath stringByReplacingOccurrencesOfString:@"./" withString:@""];
        }

        preURL = currentPath;
    }
    _javascriptUrl = [NSString stringWithFormat:@"%@%@", preURL, relativePath];


}
- (void)resetWithCurrentJSUrl:(NSURL *)url{
    [self resetWithCurrentJSUrlString:url.relativeString];
}

@end
