//
//  CNLiveShareView.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNLiveShareView : UIView
- (void)setTitle:(NSString *)title image:(id)image des:(NSString *)des shareUrl:(NSString *)shareUrl;
@property (nonatomic, copy) void(^tapShareClick)(void);
@end

NS_ASSUME_NONNULL_END
