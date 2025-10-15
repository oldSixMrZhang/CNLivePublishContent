//
//  CNLiveGetImage.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/11.
//

#import "CNLiveGetImage.h"

@implementation CNLiveGetImage
+ (UIImage *)cnliveGetImageWithName:(NSString *)name bundle:(NSString *)bundleName targetClass:(Class)targetClass {
    NSInteger scale = [[UIScreen mainScreen]scale];
    NSBundle *bundle = [NSBundle bundleForClass:targetClass];
    NSURL *url = [bundle URLForResource:bundleName withExtension:@"bundle"];
    if (!url) {
        return [UIImage new];
    }
    NSBundle *targetBundle = [NSBundle bundleWithURL:url];
    if (!targetBundle) {
        return [UIImage new];
    }
    NSString *imageName = [NSString stringWithFormat:@"%@@%zdx.png",name,scale];
    UIImage *image = [UIImage imageNamed:imageName inBundle:targetBundle compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    }else {
        if ([UIImage imageNamed:imageName inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil]) {
            return [UIImage imageNamed:imageName inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        }else {
            return [UIImage new];
        }
    }
    
}
@end
