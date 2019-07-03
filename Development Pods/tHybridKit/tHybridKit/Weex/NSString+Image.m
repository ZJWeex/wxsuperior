//
//  NSString+Image.m
//  BindingX
//
//  Created by Dao on 2019/1/24.
//

#import "NSString+Image.h"
#import "NSURL+tHybrid.h"

@implementation NSString (URL)
- (nullable UIImage *)wxImage{
    if ([self hasPrefix:@"file://"] || [self containsString: NSURL.HTTPS_RemoteResourceBase] || [self containsString:NSURL.HTTP_RemoteResourceBase]) {
        NSString *imageFile = self;
        if ([self hasPrefix:@"https://"]) {
            if ([self containsString: NSURL.HTTPS_RemoteResourceBase]) {
                imageFile = [self stringByReplacingOccurrencesOfString:NSURL.HTTPS_RemoteResourceBase withString:@""];
            }
        } else if ([self hasPrefix:@"http://"]) {
            if ([self containsString:NSURL.HTTP_RemoteResourceBase]) {
                imageFile = [self stringByReplacingOccurrencesOfString:NSURL.HTTP_RemoteResourceBase withString:@""];
            }
        }
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        imageFile = [bundlePath stringByAppendingPathComponent:imageFile];
        //        UIImage *image = [UIImage imageWithContentsOfFile:imageFile];
        UIImage *image = [UIImage imageNamed:[imageFile componentsSeparatedByString:@"."].firstObject inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:NULL];
        return image;
    }

    return nil;
}

- (nullable NSURL *)wxURL{
    if ([self containsString: NSURL.HTTPS_RemoteResourceBase]) {
        NSString *image = [self stringByReplacingOccurrencesOfString:NSURL.HTTPS_RemoteResourceBase withString:NSURL.HTTP_RemoteResourceBase];
        return [NSURL URLWithString:image];
    } else if ([self containsString:NSURL.HTTP_RemoteResourceBase]) {
        NSString *image = [self stringByReplacingOccurrencesOfString:NSURL.HTTP_RemoteResourceBase withString:NSURL.HTTP_RemoteResourceReplace];
        return [NSURL URLWithString:image];
    }else if ([self hasPrefix:@"https://"] || [self hasPrefix:@"http://"]) {
        return [NSURL URLWithString:self];
    } else if ([self hasPrefix:@"file://"]) {
        NSString *url = [self stringByReplacingOccurrencesOfString:@"file://" withString:NSURL.HTTP_RemoteResourceReplace];
        return [NSURL URLWithString:url];
    }
    return nil;
}
@end
