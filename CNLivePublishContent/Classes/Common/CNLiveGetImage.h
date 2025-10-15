//
//  CNLiveGetImage.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNLiveGetImage : NSObject
+ (UIImage *)cnliveGetImageWithName:(NSString *)name bundle:(NSString *)bundleName targetClass:(Class)targetClass;
@end

NS_ASSUME_NONNULL_END
