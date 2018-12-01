//
//  CESHelper.h
//  Archive
//
//  Created by CES on 13-5-15.
//  Copyright (c) 2013年 CES. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


/**
 根据UI设计规范自定义样式的HUD
 */
@interface MBProgressHUD (TCMHUD)

+ (instancetype)tcmTextHudInView:(UIView *)targetView;

@end

@interface CESHelper : NSObject

+ (void)showWaitingHubWithMsg:(NSString *)msg detailMsg:(NSString *)detail fromView:(UIView *)view timeInterval:(NSTimeInterval)timeInterval;

+ (void)showPromptHUBWithMsg:(NSString *)msg completionBlock:(MBProgressHUDCompletionBlock)completionBlock;


+ (void)showPromptHUBWithMsg:(NSString *)msg;

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail;

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail timeInterval:(NSTimeInterval)timeInterval;

+ (void)showPromptHUBWithMsg:(NSString *)msg detailMsg:(NSString *)detail fromView:(UIView *)view timeInterval:(NSTimeInterval)timeInterval;

+ (void)showWaitingHUB;

+ (void)showWaitingHUBWithMsg:(NSString *) msg detailMsg:(NSString *)detail;

+ (void)showWaitingHubWithMsg:(NSString *)msg detailMsg:(NSString*)detail timeInterval:(NSTimeInterval)timeInterval;

+ (void)showWaitingHubWithMsg:(NSString *)msg detailMsg:(NSString *)detail fromView:(UIView *)view timeInterval:(NSTimeInterval)timeInterval;



+ (void)closeHUBView;


/*
 *文件读写
 */
+ (NSString *) getFileDomain;
+ (BOOL) isFileExistsAtPath:(NSString *)path;
+ (void) writeArray:(NSArray *)arr toFile:(NSString*)fileName;
+ (NSArray *) readArrayFromFile:(NSString * )fileName;

+ (void)writeDictionary:(NSDictionary *)dictionary toFile:(NSString *)fileName;
+ (NSDictionary *)readDictionaryFromFile:(NSString *)fileName;


+ (void)archiveRootObject:(id)object toFile:(NSString *)fileName;
+ (id)unArchiveObjectWithFile:(NSString *)fileName;

+ (void)writeData:(NSData *)data toFile:(NSString *)fileName;
+ (NSData *)readDataFromFile:(NSString *)fileName;

+ (void)writeString:(NSString *)str toFile:(NSString *)fileName;
+ (NSString *)readStringFromFile:(NSString *)fileName;


#pragma mark -
+ (void)cleanImageCache;//清除图片缓存有两种情况：1，服务器版本信息变化；

//空白字符处理
+ (NSString *)clearPreviousWhiteSpaceCharacter:(NSString *)str;
+ (NSString *)clearBackWhiteSpaceCharacter:(NSString *)str;
+ (NSString *)trim:(NSString *)str;

+ (BOOL)isValidPhoneNumber:(NSString *)phoneNumber;

+ (NSString *)uuid;
+ (NSString *)getIMEI;

//+ (long long )newTimestampWithTime:(NSString*)time;



/**
 获取URL中的参数

 @param url 网址
 @return 参数
 */
+ (NSDictionary*)getParameterOfUrl:(NSString*)url;

@end
