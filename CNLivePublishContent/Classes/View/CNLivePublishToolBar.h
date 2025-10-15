//
//  CNLivePublishToolBar.h
//  Pods-CNLivePublishContent_Example
//
//  Created by 殷巧娟 on 2019/6/4.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>
#define PublishToolBarHeight 95
#define PublishToolEmotionHeight 50
NS_ASSUME_NONNULL_BEGIN
//index: 0-emotion 1-seleLocationBtn
typedef void(^ToolBarClick)(QMUIButton *btn ,NSInteger index);
@interface CNLivePublishToolBar : UIView
@property (nonatomic ,strong) QMUIButton *emotionBtn;
@property (nonatomic ,strong) QMUIButton *locationBtn;
@property (nonatomic ,strong) QMUIButton *seleLocationBtn;
@property (nonatomic ,copy) ToolBarClick  toolBarClick;
@property (nonatomic ,strong) UIActivityIndicatorView *indicator;
@property (nonatomic ,strong) UIView *line;
@property (nonatomic ,copy) NSString *publishType;
@end

NS_ASSUME_NONNULL_END
