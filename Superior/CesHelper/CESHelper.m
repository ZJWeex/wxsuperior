//
//  CESHelper.m
//  Archive
//
//  Created by CES on 13-5-15.
//  Copyright (c) 2013年 CES. All rights reserved.
//

#import "CESHelper.h"
#import <UIImage+GIF.h>
#import <SDWebImageManager.h>

#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
if(!shared##className){\
shared##className = [[self alloc] init];\
}\
}); \
return shared##className; \
}

#define IPHONE_SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define IPHONE_SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)

#define WeakObj(o) __weak typeof(o) o##Weak = o;
#define StrongObj(o) __strong typeof(o) o = o##Weak;


@interface TCMImageViewForHUD : UIImageView @end
@implementation TCMImageViewForHUD
-(CGSize)intrinsicContentSize{return CGSizeMake(IPHONE_SCREEN_WIDTH*.18, IPHONE_SCREEN_WIDTH*.18);}@end

@implementation MBProgressHUD (TCMHUD)

+ (instancetype)tcmTextHudInView:(UIView *)targetView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:targetView animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    
    hud.backgroundView.color = [UIColor clearColor];
    
    //需求号142 修改背景色为60%黑色
    hud.bezelView.color = [UIColor.lightGrayColor colorWithAlphaComponent:0.6];
    //非模糊效果
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    //圆角半径10
    hud.bezelView.layer.cornerRadius = 10.;
    
    //标题白色
    hud.label.textColor = UIColor.whiteColor;
    //标题1XL字体
    hud.label.font = [UIFont systemFontOfSize:14];
    
    //副标题白色
    hud.detailsLabel.textColor = UIColor.whiteColor;
    //副标题1L字体
    hud.detailsLabel.font = [UIFont systemFontOfSize:14];
    
    hud.square = NO;
    
    return hud;
}

@end

@interface CESHelper ()

@property(nonatomic,strong)MBProgressHUD *hud;

DEFINE_SINGLETON_FOR_HEADER(CESHelper)

@end

@implementation CESHelper

DEFINE_SINGLETON_FOR_CLASS(CESHelper)

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail fromView:(UIView *)view timeInterval:(NSTimeInterval)timeInterval completionBlock:(MBProgressHUDCompletionBlock)completionBlock{
    
    [self clearHud];
    
    UIView *showView;
    
    if (view) {
        showView = view;
    }else if([UIApplication sharedApplication].keyWindow){
        showView = [UIApplication sharedApplication].keyWindow;
    }else{
        showView = [UIApplication sharedApplication].windows.lastObject;
    }
    
    NSString *m = msg;
    NSString *d = detail;
    
    if ([m isEqualToString:@"NSURLErrorDomain"]) {
        m = @"网络出了点小问题，请重试下哦~";
    }
    
    if((d.length == 0) && (m.length > 10)){
        d = m;
        m = nil;
    }else if ((m.length == 0) && (d.length == 0)){
        [[CESHelper sharedCESHelper].hud hideAnimated:NO];
        return;
    }  
    
    MBProgressHUD *hud = [MBProgressHUD tcmTextHudInView:showView];
    
    hud.label.text = NSLocalizedString(m, @"HUD loading title");
    
    hud.detailsLabel.text = NSLocalizedString(d, @"HUD title");
    
    hud.minShowTime = 0.5f;
    
    if(timeInterval == 0){
        
        [hud hideAnimated:YES afterDelay:2];
        
    }else{
        [hud hideAnimated:YES afterDelay:timeInterval];
    }
    
    if (completionBlock) {
        WeakObj(hud)
        hud.completionBlock = ^{
            completionBlock();
            StrongObj(hud)
            hud.completionBlock = nil;
        };
    }
    
    [CESHelper sharedCESHelper].hud = hud;
}

+ (void)clearHud
{
    [[self sharedCESHelper].hud removeFromSuperview];
}

+ (void)showWaitingHubWithMsg:(NSString *)msg detailMsg:(NSString *)detail fromView:(UIView *)view timeInterval:(NSTimeInterval)timeInterval{
    
    [self clearHud];
    
    UIView *showView;
    
    if (view) {
        showView = view;
    }else if([UIApplication sharedApplication].keyWindow){
        showView = [UIApplication sharedApplication].keyWindow;
    }else{
        showView = [UIApplication sharedApplication].windows.lastObject;
    }
    
    NSString *m = msg;
    NSString *d = detail;
    
    if((!d.length) && (m.length > 10)){
        d = m;
        m = nil;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.margin = 0;
    
    hud.backgroundView.color = [UIColor colorWithRed:1/255.0 green:1/255.0 blue:1/255.0 alpha:0.35];
    
    hud.bezelView.color = [UIColor colorWithWhite:1.f alpha:0.9f];
    
    hud.label.textColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    
    hud.detailsLabel.textColor = [UIColor colorWithWhite:0.f alpha:0.7f];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadingCenter" ofType:@"gif"];

    NSData *data = [NSData dataWithContentsOfFile:path];

    UIImage *image = [UIImage sd_animatedGIFWithData:data];
    
    TCMImageViewForHUD *iv = [[TCMImageViewForHUD alloc] initWithImage:image];

    hud.customView = iv;
    
    hud.square = NO;
    
    hud.minShowTime = 0.1f;
    
//    hud.label.text = NSLocalizedString(m, @"HUD loading title");
//
//    hud.detailsLabel.text = NSLocalizedString(d, @"HUD title");

    if(timeInterval > 0){
        
        [hud hideAnimated:YES afterDelay:timeInterval];
        
    }else{
        
        [hud hideAnimated:YES afterDelay:10];
    }
    
    hud.completionBlock = nil;
    
    [CESHelper sharedCESHelper].hud = hud;
}

+ (void)showPromptHUBWithMsg:(NSString *)msg completionBlock:(MBProgressHUDCompletionBlock)completionBlock{
    [self showPromptHUBWithMsg:msg detailMsg:nil fromView:nil timeInterval:0 completionBlock:completionBlock];
}

+ (void)showPromptHUBWithMsg:(NSString *)msg{
    [self showPromptHUBWithMsg:msg detailMsg:nil fromView:nil timeInterval:0 completionBlock:nil];
}

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail{
    [self showPromptHUBWithMsg:msg detailMsg:detail fromView:nil timeInterval:0 completionBlock:nil];
}

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail timeInterval:(NSTimeInterval)timeInterval{
    [self showPromptHUBWithMsg:msg detailMsg:detail fromView:nil timeInterval:timeInterval completionBlock:nil];
}

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail fromView:(UIView *)view timeInterval:(NSTimeInterval)timeInterval{
    [self showPromptHUBWithMsg:msg detailMsg:detail fromView:view timeInterval:timeInterval completionBlock:nil];
}



+ (void)showWaitingHUB{
    [self showWaitingHubWithMsg:nil detailMsg:nil fromView:nil timeInterval:0];
}


+ (void)showWaitingHUBWithMsg:(NSString *) msg detailMsg:(NSString *)detail{
    [self showWaitingHubWithMsg:msg detailMsg:detail fromView:nil timeInterval:0];
}


+ (void)showWaitingHubWithMsg:(NSString *)msg detailMsg:(NSString*)detail timeInterval:(NSTimeInterval)timeInterval{
    [self showWaitingHubWithMsg:msg detailMsg:detail fromView:nil timeInterval:timeInterval];
}


+ (void)closeHUBView{
    [[CESHelper sharedCESHelper].hud hideAnimated:YES];
}

+(void)closeAction{
    [[CESHelper sharedCESHelper].hud hideAnimated:YES];
}

#pragma mark - file manager

+ (NSString*) getFileDomain{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString * directoryPath = [[paths objectAtIndex:0] stringByAppendingFormat:@"/%@", @"custom_directory"];
    
    if (![CESHelper isFileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:0];
    }
    
    return directoryPath;
}

+ (BOOL) isFileExistsAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        return NO;
    }
    return YES;
}

+ (void) writeArray:(NSArray *)arr toFile:(NSString*)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if (![CESHelper isFileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [arr writeToFile:filePath atomically:YES];
}

+ (NSArray *) readArrayFromFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if(![CESHelper isFileExistsAtPath:filePath])
        return nil;
    else
        return [NSArray arrayWithContentsOfFile:filePath];
}

+ (void)writeDictionary:(NSDictionary *)dictionary toFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if (![CESHelper isFileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [dictionary writeToFile:filePath atomically:YES];
}

+ (NSDictionary *)readDictionaryFromFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if(![CESHelper isFileExistsAtPath:filePath])
        return nil;
    else
        return [NSDictionary dictionaryWithContentsOfFile:filePath];
}


+ (void)archiveRootObject:(id)object toFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if (![CESHelper isFileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [NSKeyedArchiver archiveRootObject:object toFile:filePath];
}


+ (id)unArchiveObjectWithFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if(![CESHelper isFileExistsAtPath:filePath])
        return nil;
    else
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+ (void)writeData:(NSData *)data toFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if (![CESHelper isFileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [data writeToFile:filePath atomically:YES];
}

+ (NSData *)readDataFromFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if(![CESHelper isFileExistsAtPath:filePath])
        return nil;
    else
        return [NSData dataWithContentsOfFile:filePath];
}

+ (void)writeString:(NSString *)str toFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if (![CESHelper isFileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:0];
}

+ (NSString *)readStringFromFile:(NSString *)fileName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CESHelper getFileDomain], fileName];
    if(![CESHelper isFileExistsAtPath:filePath])
        return nil;
    else
        return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:0];
}



#pragma mark -

+ (void)cleanImageCache{
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    [manager.imageCache clearMemory];
}

+ (NSString *)clearPreviousWhiteSpaceCharacter:(NSString *)str{
    if (!str.length) {
        return str;
    }
    NSInteger i = 0;
    NSInteger len = str.length;
    for (; i < len; i++) {
        NSString * sub = [str substringWithRange:NSMakeRange(0, 1)];
        if (![sub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length) {
            if (str.length > 1) {
                str = [str substringFromIndex:1];
            }else{
                str = [sub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
        }else{
            break;
        }
    }
    
    return str;
}
+ (NSString *)clearBackWhiteSpaceCharacter:(NSString *)str{
    if (!str.length) {
        return str;
    }
    NSInteger i = str.length - 1;
    for (; i >= 0; i--) {
        NSString * sub = [str substringWithRange:NSMakeRange(i, 1)];
        if (![sub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length) {
            if (i > 0) {
                str = [str substringToIndex:i];
            }else{
                str = [sub stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
        }else{
            break;
        }
    }
    
    return str;
}
+ (NSString *)trim:(NSString *)str{
    str = [CESHelper clearPreviousWhiteSpaceCharacter:str];
    str = [CESHelper clearBackWhiteSpaceCharacter:str];
    return str;
}


+ (BOOL)isValidPhoneNumber:(NSString *)phoneNumber{
    if (![phoneNumber length]){
        return NO;
    }
    NSString * format = @"(^(1[3\\5\\7\\8][0-9]{9})$)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format];
    return [pred evaluateWithObject:phoneNumber];
}


+ (NSString *)uuid{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

+ (NSString *)getIMEI{
    UIPasteboard * pb = [UIPasteboard pasteboardWithName:@"com.sl.LLDai" create:YES];
    NSString * imei = pb.string;
    if (!imei.length) {
        imei = [self uuid];
        pb.string = imei;
    }
    return imei;
}

+ (long long)timestampWithTime:(NSString*)time
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh"]];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:time];
    long long timestamp = [date timeIntervalSince1970]*1000;
    return timestamp;
}


+ (NSDictionary*)getParameterOfUrl:(NSString*)url;
{
    NSRange range = [url rangeOfString:@"?"];
    if (range.length) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *parameterUrl = [url substringFromIndex:range.location+1];
        NSArray *parameterArr = [parameterUrl componentsSeparatedByString:@"&"];
        for (NSString *parameter in parameterArr) {
            NSArray *parameterBoby = [parameter componentsSeparatedByString:@"="];
            if (parameterBoby.count == 2) {
                [dic setObject:parameterBoby[1] forKey:parameterBoby[0]];
            }
        }
        return dic;
    }
    return nil;
}

@end
