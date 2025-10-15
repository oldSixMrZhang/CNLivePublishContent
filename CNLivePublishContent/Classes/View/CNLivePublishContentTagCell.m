//
//  CNLivePublishContentTagCell.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import "CNLivePublishContentTagCell.h"
#import "QMUIKit.h"
#import "CNLiveFloatLayoutView.h"
#import "CNLiveDefinesHeader.h"
#import "Masonry.h"
#import "YYKit.h"
#import "CNLiveGetImage.h"
// 弱引用
#define MJWeakSelf __weak typeof(self) weakSelf = self;
@interface CNLivePublishContentTagCell ()
@property (nonatomic, strong) QMUIButton *tagBtn;
@property (nonatomic, strong) QMUIButton *showBtn;
@property (nonatomic, strong) CNLiveFloatLayoutView *tagLayoutView;
@property (nonatomic, strong) QMUIButton *tagButton;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *tagIdArray;
@end

@implementation CNLivePublishContentTagCell

-(instancetype)initForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initForTableView:tableView withStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initWithSubViews];
    }
    return self;
}
-(void)initWithSubViews {
    [self addSubview:self.tagBtn];
    [self addSubview:self.showBtn];
    [self addSubview:self.tagLayoutView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heightChangeAction:) name:@"heightChange" object:nil];
    [self setUpLayoutFrame];
    
}
-(void)setUpLayoutFrame {
    MJWeakSelf;
    [_tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(11);
        make.left.mas_equalTo(weakSelf.mas_left).offset(20);
        make.width.mas_equalTo(60*RATIO);
        make.height.mas_equalTo(20*RATIO);
    }];
    [_showBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.tagBtn.mas_centerY);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-10);
        //        make.height.width.mas_equalTo(20*RATIO);
        make.height.mas_equalTo(20*RATIO);
        make.width.mas_equalTo(60*RATIO);
    }];
    [_tagLayoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.mas_left).offset(8);
        make.top.mas_equalTo(weakSelf.tagBtn.mas_bottom).offset(10);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-8);
        make.height.mas_equalTo(0);
    }];
}
-(void)setWitnessModel:(CNLiveWitnessModel *)witnessModel
{
    
    _witnessModel = witnessModel;
    _index = witnessModel.tagId;
    
}
-(void)setTagId:(NSInteger)tagId{
    _tagId = tagId;
}
-(void)setTagArray:(NSArray *)tagArray {
    MJWeakSelf;
    _tagArray = tagArray;
    [_tagLayoutView removeAllSubviews];
    _buttonArray = [NSMutableArray array];
    __block CGSize floatLayoutViewSize;
    NSMutableArray *tagArr = [NSMutableArray array];
    NSMutableArray *tagIdArr = [NSMutableArray array];
    self.tagIdArray = [NSMutableArray array];
    if (tagArray.count > 0) {
        for (NSDictionary *tagDic in tagArray) {
            [tagArr addObject:[tagDic objectForKey:@"tagName"]];
            [self.tagIdArray addObject:[tagDic objectForKey:@"tagId"]];
        }
    }
    @autoreleasepool {
        for (int i = 0; i < tagArray.count; i++) {
            QMUIButton *button= [[QMUIButton alloc]init];
            [button setTitle:tagArr[i] forState:UIControlStateNormal];
            CGFloat contentWidth = KScreenWidth-16;
            floatLayoutViewSize = [self.tagLayoutView sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
            button.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 6, 20);
            button.layer.cornerRadius = 15;
            [button addTarget:self action:@selector(tagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = UIFontMake(16.0f);
            button.enabled = YES;
            button.userInteractionEnabled = YES;
            [button setTitleColor:[UIColor qmui_colorWithHexString:@"#666666"] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor qmui_colorWithHexString:@"#F9F9F9"]];
            button.tag = 101 + i;
            self.showTagId = [self.tagIdArray[i] integerValue];
            button.accessibilityValue  = self.tagIdArray[i];
            [self.tagLayoutView addSubview:button];
            [_buttonArray addObject:button];
        }
    }
    [_tagLayoutView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.mas_left).offset(8);
        make.top.mas_equalTo(weakSelf.tagBtn.mas_bottom).offset(10);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-8);
        make.height.mas_equalTo(floatLayoutViewSize.height);
    }];
    
    [self layoutIfNeeded];
}


-(QMUIButton *)tagBtn {
    if (!_tagBtn) {
        _tagBtn = [[QMUIButton alloc]init];
        [_tagBtn setTitleColor:UIColorMake(51, 51,51) forState:UIControlStateNormal];
        [_tagBtn setTitle:@"标签" forState:UIControlStateNormal];
//        [_tagBtn setImage:[UIImage imageNamed:@"mjz_bq"] forState:UIControlStateNormal];
        [_tagBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"mjz_bq" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateNormal];
        _tagBtn.imagePosition = QMUIButtonImagePositionLeft;
        _tagBtn.spacingBetweenImageAndTitle = 10;
        _tagBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
        _tagBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _tagBtn.titleLabel.font = UIFontCNMake(16);
        _tagBtn.userInteractionEnabled = NO;
    }
    return _tagBtn;
}
-(QMUIButton *)showBtn {
    if (!_showBtn) {
        _showBtn = [[QMUIButton alloc]init];
//        [_showBtn setImage:[UIImage imageNamed:@"mjz_sq"] forState:UIControlStateNormal];
        [_showBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"mjz_sq" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateNormal];
        _showBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [_showBtn setImage:[UIImage imageNamed:@"mjz_zk"] forState:UIControlStateSelected];
        [_showBtn setImage:[CNLiveGetImage cnliveGetImageWithName:@"mjz_zk" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]] forState:UIControlStateSelected];
        _showBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
        [_showBtn addTarget:self action:@selector(showBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showBtn;
}
-(CNLiveFloatLayoutView *)tagLayoutView {
    if (!_tagLayoutView) {
        _tagLayoutView = [[CNLiveFloatLayoutView alloc]init];
        _tagLayoutView.padding = UIEdgeInsetsMake(12, 12, 12, 12);
        _tagLayoutView.itemMargins = UIEdgeInsetsMake(0, 0, 10, 10);
        _tagLayoutView.minimumItemSize = CGSizeMake(60, 29);
        _tagLayoutView.zxMaxShowLinesCount = 100;
    }
    return _tagLayoutView;
}

-(void)tagButtonAction:(QMUIButton *)sender{
    //    NSLog(@"打印啊啊啊啊%ld",self.tagId);
    NSString  * titleStr ;
    
    if (!_tagButton) {
        sender.backgroundColor = [UIColor qmui_colorWithHexString:@"#FF23D41E"];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _tagButton = sender;
        _tagButton.selected = YES;
        //        NSLog(@"第一次进来选中");
        titleStr = sender.titleLabel.text;
        if (self.tagBtnBlock) {
            self.tagBtnBlock(titleStr, sender.tag - 100, _tagArray,[sender.accessibilityValue integerValue]);
        }
        self.tagId = sender.tag - 100;
        self.showTagId = [sender.accessibilityValue integerValue];
        //        return;
    } else if (_tagButton == sender && _tagButton.selected == YES ) {
        sender.backgroundColor = [UIColor qmui_colorWithHexString:@"#F9F9F9"];
        [sender setTitleColor:[UIColor qmui_colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        _tagButton.selected = NO;
        _tagButton = nil;
        titleStr = @"";
        self.tagId = 0;
        self.showTagId = 0;
        if (self.tagBtnBlock) {
            self.tagBtnBlock(titleStr, self.tagId, _tagArray,self.showTagId);
        }
        //        NSLog(@"取消选中");
    } else if (_tagButton != sender) {
        _tagButton.backgroundColor = [UIColor qmui_colorWithHexString:@"#F9F9F9"];
        [_tagButton setTitleColor:[UIColor qmui_colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor qmui_colorWithHexString:@"#FF23D41E"];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sender.selected = YES;
        _tagButton = sender;
        titleStr = sender.titleLabel.text;
        if (self.tagBtnBlock) {
            self.tagBtnBlock(titleStr, sender.tag - 100, _tagArray,[sender.accessibilityValue integerValue]);
        }
        self.tagId = sender.tag - 100;
        self.showTagId = [sender.accessibilityValue integerValue];
        //        NSLog(@"有选中,切换选中");
    }else if (_tagButton && self.tagId > 0) {
        sender.backgroundColor = [UIColor qmui_colorWithHexString:@"#F9F9F9"];
        _tagButton.selected = NO;
        _tagButton = nil;
        self.tagId = 0;
        titleStr = @"";
        self.showTagId = 0;
        if (self.tagBtnBlock) {
            self.tagBtnBlock(titleStr, self.tagId, _tagArray,self.showTagId);
        }
        
    }
}
-(void)setSelectedBtn:(NSInteger)idx
{
    
    if (_buttonArray.count > 1) {
        QMUIButton *button = _buttonArray[idx];
        _tagButton.backgroundColor = [UIColor qmui_colorWithHexString:@"#F9F9F9"];
        [_tagButton setTitleColor:[UIColor qmui_colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor qmui_colorWithHexString:@"#FF23D41E"];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _tagButton = button;
    }else if (_buttonArray.count == 1){
        QMUIButton *button = _buttonArray[0];
        _tagButton.backgroundColor = [UIColor qmui_colorWithHexString:@"#F9F9F9"];
        [_tagButton setTitleColor:[UIColor qmui_colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor qmui_colorWithHexString:@"#FF23D41E"];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _tagButton = button;
        if (_witnessModel.isEdit) {
            self.showBtn.userInteractionEnabled = NO;
            button.userInteractionEnabled = NO;
        }
    }
}

-(void)showBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        _tagLayoutView.zxMaxShowLinesCount = 0;
        [_tagLayoutView setNeedsLayout];
        [_tagLayoutView layoutIfNeeded];
        [self setTagArray:_tagArray];
        
    }else {
        _tagLayoutView.zxMaxShowLinesCount = 100;
        [self setTagArray:_tagArray];
        [_tagLayoutView setNeedsLayout];
        [_tagLayoutView layoutIfNeeded];
        if (self.tagId > 0) {
            [self setSelectedBtn:self.tagId - 1];
        }
    }
}

- (void)heightChangeAction:(NSNotification *)noti
{
    MJWeakSelf;
    NSNumber *num = noti.object;
    CGFloat number = num.floatValue;
    NSLog(@"number:%f",number);
    [_tagLayoutView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.mas_left).offset(8);
        make.top.mas_equalTo(weakSelf.tagBtn.mas_bottom).offset(10);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-8);
        make.height.mas_equalTo(number);
    }];
}

@end
