//
//  QMUIEmotion+CNLiveEmotion.h
//  CNLiveNetAdd
//
//  Created by 张旭 on 2018/11/3.
//  Copyright © 2018 cnlive. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define CNLiveResourcesQQEmotionBundleName @"CNLive_QQEmotion.bundle"

@interface QMUIEmotion (CNLiveEmotion)

+ (UIImage *)cnliveImageWithEmotion:(QMUIEmotion *)emotion;

@end

NS_ASSUME_NONNULL_END
