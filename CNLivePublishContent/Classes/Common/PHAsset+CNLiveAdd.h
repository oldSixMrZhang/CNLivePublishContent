//
//  PHAsset+CNLiveAdd.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (CNLiveAdd)
+ (NSURL *)movieURL:(PHAsset*)asset;
+ (NSString *)getVideoTime:(PHAsset *)asset;
+ (NSInteger)returnVideoTime:(PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
