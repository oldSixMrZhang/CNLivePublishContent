//
//  CNLivePublishToolBar.m
//  Pods-CNLivePublishContent_Example
//
//  Created by 殷巧娟 on 2019/6/4.
//

#import "CNLivePublishToolBar.h"
#import "UIView+Extension.h"
#import "CNLiveGetImage.h"
@interface CNLivePublishToolBar ()
@property (nonatomic, strong) UIView *line1;
@end

@implementation CNLivePublishToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
//        self.backgroundColor = [UIColor cyanColor];
        // 添加所有子控件
        [self setUpAllChildView];
    }
    return self;
}
-(void)setPublishType:(NSString *)publishType {
    _publishType = publishType;
    if ([self.publishType isEqualToString:@"witness"]) {
        _line1.top = 0;
        _emotionBtn.top = 1;
    }else {
        _line1.top = 44;
        _emotionBtn.top = PublishToolBarHeight - PublishToolEmotionHeight;
    }
}
#pragma mark - 添加所有子控件
- (void)setUpAllChildView
{
    _line = [[UIView alloc] initWithFrame:CGRectFlatMake(0, 0, self.width, 0.5)];
    _line.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    [self addSubview:_line];
    
    _line1 = [[UIView alloc] initWithFrame:CGRectFlatMake(0, 44, self.width, 0.5)];
    _line1.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    [self addSubview:_line1];
    UIView *botline = [[UIView alloc] initWithFrame:CGRectFlatMake(0, self.height-1, self.width, 0.5)];
    botline.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    [self addSubview:botline];
    _emotionBtn = [[QMUIButton alloc] initWithFrame:CGRectFlatMake(0, PublishToolBarHeight - PublishToolEmotionHeight, PublishToolEmotionHeight, PublishToolEmotionHeight)];
    [_emotionBtn addTarget:self action:@selector(emotionAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_emotionBtn setImage:[UIImage imageNamed:@"xx_emoji"] forState:UIControlStateNormal];
    [_emotionBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"chat_emoji" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateNormal];
//    [_emotionBtn setImage:[UIImage imageNamed:@"xx_emoji_selected"] forState:UIControlStateSelected];
//    _emotionBtn.backgroundColor = [UIColor cyanColor];
    [_emotionBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"chat_emoji_hover" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateSelected];
    [self addSubview:_emotionBtn];
    _seleLocationBtn = [[QMUIButton alloc] initWithFrame:CGRectFlatMake(self.width - PublishToolBarHeight + PublishToolEmotionHeight, 0, PublishToolBarHeight - PublishToolEmotionHeight, PublishToolBarHeight - PublishToolEmotionHeight)];
    [_seleLocationBtn addTarget:self action:@selector(seleLocationAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_seleLocationBtn setImage:[UIImage imageNamed:@"fb_weixuan"] forState:UIControlStateNormal];
    [_seleLocationBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"fb_weixuan" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateNormal];
//    [_seleLocationBtn setImage:[UIImage imageNamed:@"fb_xuanzhong"] forState:UIControlStateSelected];
    [_seleLocationBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"fb_xuanzhong" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateSelected];
    [self addSubview:_seleLocationBtn];
    _seleLocationBtn.selected = YES;
    _locationBtn = [[QMUIButton alloc] initWithFrame:CGRectMake(10, 0, 100, PublishToolBarHeight - PublishToolEmotionHeight)];
    [_locationBtn setTitleColor:UIColorMake(40, 40, 40) forState:UIControlStateNormal];
    [_locationBtn setTitle:@"获取位置中" forState:UIControlStateNormal];
    [_locationBtn.titleLabel setFont:UIFontMake(15)];
    [self addSubview:_locationBtn];
//    [_locationBtn setImage:[UIImage imageNamed:@"fb_weizhi"] forState:UIControlStateNormal];
    [_locationBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"fb_weizhi" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateNormal];
    _locationBtn.userInteractionEnabled = NO;
    _locationBtn.imagePosition = QMUIButtonImagePositionLeft;
    _locationBtn.spacingBetweenImageAndTitle = 10;
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleGray];
    _indicator.center = CGPointMake(CGRectGetMaxX(_locationBtn.frame)+10,_locationBtn.frame.size.height *0.5);
    [_indicator startAnimating];
    [_indicator setHidesWhenStopped:YES];
    [self addSubview:_indicator];
}
#pragma mark - Action
- (void)emotionAction:(QMUIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.toolBarClick) {
        self.toolBarClick(btn, 0);
    }
}

- (void)seleLocationAction:(QMUIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.toolBarClick) {
        self.toolBarClick(btn, 1);
    }
}

@end
