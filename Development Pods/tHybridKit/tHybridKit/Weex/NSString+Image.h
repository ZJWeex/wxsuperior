//
//  NSString+Image.h
//  BindingX
//
//  Created by Dao on 2019/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Image)

/**获取string对应的图片[限本地图片]*/
- (nullable UIImage *)wxImage;
/**获取string对应的URL*/
- (nullable NSURL *)wxURL;

@end

NS_ASSUME_NONNULL_END
