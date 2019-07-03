//
//  TCMWeexImageLoader.m
//  Weex
//
//  Created by Dao on 2017/12/29.
//  Copyright © 2017年 Taocaimall. All rights reserved.
//

#import "TCMWeexImageLoader.h"
#import "NSString+Image.h"
#import "SDWebImageManager.h"

UIImage *thybrid_CrateGiftImage(NSData * dataImage, UIImage *image);


@interface TCMWeexImageLoader ()<WXImageOperationProtocol>

@end

@implementation TCMWeexImageLoader


- (id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)options completed:(void (^)(UIImage *, NSError *, BOOL))completedBlock {

    if (!completedBlock) {
        return self;
    }
    UIImage *image = url.wxImage;
    if (image) {
        completedBlock(image, nil, YES);
        return self;
    }

    return (id<WXImageOperationProtocol>)[[SDWebImageManager sharedManager] loadImageWithURL:url.wxURL options:(0) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        completedBlock([UIImage imageNamed:@"defaultImage"], nil, NO);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {

        if (image.images) {
            image = thybrid_CrateGiftImage(data, image);
        }
        completedBlock( image, error, finished);
    }];
}



- (void)cancel {

}

@end
/**
 GIF动画
 
 @param dataImage <#dataImage description#>
 @param image <#image description#>
 @return <#return value description#>
 */
UIImage *thybrid_CrateGiftImage(NSData * dataImage, UIImage *image) {

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)dataImage, NULL);
    size_t count = CGImageSourceGetCount(source);

    CGFloat scale = [UIScreen mainScreen].scale;

    NSMutableArray *arrFrameImages = [NSMutableArray array];

    for (int i = 0; i < count; i++) {
        CGImageRef CGImage = CGImageSourceCreateImageAtIndex(source, i, NULL);

        UIImage *frameImage = [UIImage imageWithCGImage:CGImage scale:scale orientation:UIImageOrientationUp];

        [arrFrameImages addObject:frameImage];

        CGImageRelease(CGImage);
    }

    UIImage *animatedImage = [UIImage animatedImageWithImages:arrFrameImages duration:image.duration *count];

    CFRelease(source);
    return animatedImage;

}
