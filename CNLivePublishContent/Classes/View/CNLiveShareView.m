//
//  CNLiveShareView.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import "CNLiveShareView.h"
#import "QMUIKit.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "CNLiveConst.h"
#import "CNLiveDefinesHeader.h"
#define kGuangbiaoColor [UIColor colorWithRed:0.20 green:0.35 blue:0.95 alpha:1.00]
@interface CNLiveShareView ()
@property (nonatomic, strong) UIView *shareView; //分享的那个View
@property (nonatomic, strong) UIImageView *shareImageV;
@property (nonatomic, strong) QMUILabel *shareTitleL;
@end


@implementation CNLiveShareView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithViews];
    }
    return self;
}
-(void)initWithViews {
    
    //    _shareView.backgroundColor = UIColorMake(243, 243, 246);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLink)];
    [self addGestureRecognizer:tap];
    //    _shareView.hidden = YES;
    CGFloat padding = 6;
    _shareImageV = [[UIImageView alloc]init];
    _shareImageV.frame = CGRectMake(padding, padding, ZXShareHeight*RATIO -2*padding,ZXShareHeight*RATIO -2*padding);
    [self addSubview:_shareImageV];
    _shareTitleL = [[QMUILabel alloc]init];
    _shareTitleL.text = @"链接";
    _shareTitleL.font = UIFontCNMake(14);
    _shareTitleL.tintColor = kGuangbiaoColor;
    _shareTitleL.numberOfLines = 0;
    _shareTitleL.textAlignment = NSTextAlignmentLeft;
    _shareTitleL.frame = CGRectMake(CGRectGetMaxX(_shareImageV.frame) + padding, padding, KScreenWidth - ZXShareHeight*RATIO - 2*ZXMargin, ZXShareHeight*RATIO -2*padding);
    [self addSubview:_shareTitleL];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    //    [self SetFrame];
    
}
-(void)tapLink {
    if (self.tapShareClick) {
        self.tapShareClick();
    }
}
-(void)setTitle:(NSString *)title image:(id)image des:(NSString *)des shareUrl:(NSString *)shareUrl {
    _shareTitleL.text = title ? title:@"";
//    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
//    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    [_shareImageV sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:nil];
}


@end
