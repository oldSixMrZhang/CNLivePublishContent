//
//  CNLivePublishContentCell.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import "CNLivePublishContentCell.h"
#import "CNLiveShareView.h"
#import "Masonry.h"
#import "CNLiveConst.h"
#import "TZTestCell.h"
#import "LxGridViewFlowLayout.h"
#import "CNLivePublishContentLayout.h"
#import "CNLiveWitnessModel.h"
#import "CNLiveDefinesHeader.h"
#import "CNImagePickerManager.h"
#import "CNLivePublishContentLayout.h"
#import "CNLiveGetImage.h"
#define kGuangbiaoColor [UIColor colorWithRed:0.20 green:0.35 blue:0.95 alpha:1.00]
@interface CNLivePublishContentCell ()<QMUITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    BOOL _isSelectOriginalPhoto;
}
@property (nonatomic, strong) LxGridViewFlowLayout *layout;
@property (assign, nonatomic) CGFloat itemWH;
@property (assign, nonatomic) CGFloat margin;
@property (assign, nonatomic) CGFloat collHeight;
@property (assign, nonatomic) NSInteger isSelectVideo;
@property (assign, nonatomic) NSInteger contentSizeH;
@end


@implementation CNLivePublishContentCell

-(instancetype)initForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initForTableView:tableView withStyle:style reuseIdentifier:reuseIdentifier];
    [self initWithSubViews];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    if (CNAppDelegate.draftModel) {
//        if ([CNAppDelegate.draftModel.videoType isEqualToString:@"witness"]) {
//            self.titleTextView.placeholder = @"我在现场，我要说……（字数不超过140个字)";
//            self.titleTextView.maximumTextLength = 140;
//        }else {
//            self.titleTextView.placeholder = @"这一刻的想法...";
//            self.titleTextView.maximumTextLength = 10000;
//        }
//    }
    return self;
}
-(void)initWithSubViews {
    [self.contentView addSubview:self.shareView];
    [self.contentView addSubview:self.titleTextView];
    [self setUpCollectionView];
    [self setUpLayoutFrame];
}
#pragma mark -创建collectionView
-(void)setUpCollectionView {
    _isSelectVideo = 1;
    _layout = [[LxGridViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:rgb
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:_collectionView];
    _collectionView.hidden = NO;
    [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
    _collectionView.scrollEnabled = NO;
    [self setUpLayoutFrame];
    
}
-(void)setUpLayoutFrame {
    [_titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat padding = 10;
        make.left.mas_equalTo(padding);
        make.top.mas_equalTo(self).offset(2*padding);
        make.right.mas_equalTo(-padding);
        make.height.mas_equalTo(144*RATIO);
    }];
    [_shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self->_titleTextView.mas_bottom).offset(ZXMargin);
        make.left.mas_equalTo(self.contentView.mas_left).offset(ZXMargin);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-ZXMargin);
        make.height.mas_equalTo(ZXShareHeight*RATIO);
    }];
    _contentSizeH = 8;
    _margin = 4;
    _itemWH = (KScreenWidth - 2 * _margin - 4) / 3 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    [self.collectionView setCollectionViewLayout:_layout];
    _collHeight = _itemWH + 10;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView).offset(0);
        make.top.mas_equalTo(self->_titleTextView.mas_bottom).offset(10);
        make.height.mas_equalTo(self->_itemWH+10);
    }];
   
    
}

-(void)setPublishType:(NSString *)publishType {
    
    _publishType = publishType;
    if ([self.publishType isEqualToString:@"witness"]){
        self.titleTextView.maximumTextLength = 140;
        self.titleTextView.placeholder = @"我在现场，我要说……（字数不超过140个字)";
    }else {
        self.titleTextView.maximumTextLength = 10000;
        self.titleTextView.placeholder = @"这一刻的想法...";
    }
}
-(void)setPublishContentType:(CNLivePublishContentTypes)publishContentType {
    _publishContentType = publishContentType;
    if (_publishContentType == CNLivePublishWitnessContentTypeShare) {
        self.shareView.hidden = NO;
        self.collectionView.hidden = YES;
    }else {
        self.shareView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}
- (void)setSelectedAssets:(NSMutableArray *)selectedAssets{
    _selectedAssets = selectedAssets;
}
- (void)setSelectedPhotos:(NSMutableArray *)selectedPhotos{
    _selectedPhotos = selectedPhotos;
}
-(void)setWitnessModel:(CNLiveWitnessModel *)witnessModel {
    _witnessModel = witnessModel;
    if (witnessModel.isEdit) {
        _isSelectVideo = 0;
    }
}
#pragma mark -UICollectionView Delegatef
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedPhotos.count + _isSelectVideo;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    
    cell.videoImageView.hidden = YES;
    NSLog(@"打印这里的z图片%@----%ld",_selectedPhotos,_selectedPhotos.count);
    
    if (indexPath.row == _selectedPhotos.count) {
        if (_selectedPhotos.count == 0 && _selectedAssets.count == 0) {
            if ([_publishType isEqualToString:@"witness"]||[_witnessModel.videoType isEqualToString:@"witness"]) {
                //                cell.imageView.image = [UIImage imageNamed:@"fb_tjsp"];
                cell.imageView.image = [CNLiveGetImage cnliveGetImageWithName:@"fb_tjsp" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]];
            }else {
                //                cell.imageView.image = [UIImage imageNamed:@"fb_tjsc"];
                cell.imageView.image = [CNLiveGetImage cnliveGetImageWithName:@"fb_tjsc" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]];
            }
        }else {
            //            cell.imageView.image = [UIImage imageNamed:@"fb_zctj"];
            cell.imageView.image = [CNLiveGetImage cnliveGetImageWithName:@"fb_zctj" bundle:@"CNLivePublishContent.bundle/CNLivePublishContent" targetClass:[self class]];
        }
        cell.addPicLable.hidden = YES;
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        PHAsset * assetes;
        if (_witnessModel) {
            if (_witnessModel.localIdentifier) {
                PHFetchResult * assetArray =  [PHAsset fetchAssetsWithLocalIdentifiers:@[_witnessModel.localIdentifier] options:nil];
                assetes = assetArray.firstObject;
                if (assetes != nil) {
                    cell.imageView.image = _witnessModel.videoimage;
                    cell.addPicLable.hidden = YES;
                    cell.gifLable.hidden  = YES;
                    cell.videoImageView.hidden = NO;
                    cell.asset = _selectedAssets[indexPath.row];
                    cell.deleteBtn.hidden = NO;
                }else {
                    if (_selectedPhotos.count > 0 && _selectedAssets.count > 0) {
                        cell.deleteBtn.hidden = NO;
                        cell.imageView.image = _selectedPhotos[indexPath.row];
                        cell.asset = _selectedAssets[indexPath.row];
                        cell.addPicLable.hidden = YES;
                    }
                }
            }else{
                if (_witnessModel.isEdit) {
                    cell.imageView.image = _witnessModel.videoimage;
                    cell.addPicLable.hidden = YES;
                    cell.gifLable.hidden  = YES;
                    cell.videoImageView.hidden = NO;
                    cell.deleteBtn.hidden = YES;
                }
            }
        }else {
            cell.deleteBtn.hidden = NO;
            cell.imageView.image = _selectedPhotos[indexPath.row];
            cell.asset = _selectedAssets[indexPath.row];
            cell.addPicLable.hidden = YES;
        }
    }
    
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_witnessModel.isEdit) {
        //        CNDarenCategoryWebController *webVC = [[CNDarenCategoryWebController alloc] initWithUrl:_witnessModel.shareUrl pageTitle:nil];
        //        [[AppDelegate sharedAppDelegate] pushViewController:webVC withBackTitle:@" "];
        //        [QMUITips showWithText:@"暂未开放" inView:AppKeyWindow hideAfterDelay:2];
        return;
    }else {
        if (self.cellSelectDelegate && [self.cellSelectDelegate respondsToSelector:@selector(collectionView:didSelectItemNsIndexPath:)]) {
            [self.cellSelectDelegate collectionView:collectionView didSelectItemNsIndexPath:indexPath];
        }
    }
    
}
#pragma mark - LxGridViewDataSource

// 以下三个方法为长按排序相关代码

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    [_collectionView reloadData];
}

#pragma mark -Action
-(void)deleteBtnClik:(UIButton *)sender {
    _witnessModel = nil;
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    if (self.cellSelectDelegate && [self.cellSelectDelegate respondsToSelector:@selector(deledteBtnClick:selectedAssets:)]) {
        [self.cellSelectDelegate deledteBtnClick:_selectedPhotos selectedAssets:_selectedAssets];
    }
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self updateCollectionViewWithAssets:_selectedAssets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    }];
}
#pragma mark - 更新collection
-(void)updateCollectionViewWithAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    if (_selectedPhotos.count > 0 && _selectedAssets.count > 0) {
        id ass = _selectedAssets[0];
        TZAssetModelMediaType type = [CNImagePickerManager getAssetType:ass];
        if (type == TZAssetModelMediaTypeVideo) {
            _isSelectVideo = 0 ;// 如果是视频,隐藏z选择图片按钮
            _layout.panGestureRecognizerEnable = NO;
        }else {
            if (_selectedPhotos.count == 9) {
                _isSelectVideo = 0;
                _layout.panGestureRecognizerEnable = YES;
            }else {
                _isSelectVideo = 1;
                if (_selectedPhotos.count  <= 1) {
                    _layout.panGestureRecognizerEnable = NO;
                }else {
                    _layout.panGestureRecognizerEnable = YES;
                }
            }
        }
    }else {
        _isSelectVideo = 1;
    }
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    _collHeight = 0;
    CNLivePublishContentLayout *layout = [[CNLivePublishContentLayout alloc]init];
    _collHeight = [layout conllectionViewHeight:_selectedPhotos assetArray:_selectedAssets isSelectedVideo:_isSelectVideo];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth);
        make.top.mas_equalTo(self).mas_offset(10);
        make.height.mas_equalTo(_collHeight);
    }];
    //    self.collectionView.backgroundColor = [UIColor purpleColor];
    NSLog(@"打印这个collectionView的高度%lf", _collHeight);
    [self.collectionView reloadData];
}
#pragma mark - TextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    NSInteger textTotalLength = textView.text.length + text.length;
    
    if (textTotalLength > self.titleTextView.maximumTextLength) {
        textTotalLength = self.titleTextView.maximumTextLength;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChangeTextView:)]) {
        [self.delegate textViewDidChangeTextView:textView];
    }
}
- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height {
    CGFloat maxHeight = 200*RATIO;
    CGFloat minHeight = 144*RATIO;
    height = fmin(maxHeight, fmax(height, minHeight));
    BOOL needsChangeHeight = CGRectGetHeight(textView.frame) != height;
    if (needsChangeHeight) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldBeginEditingTextView:)]) {
        [self.delegate shouldBeginEditingTextView:textView];
    }
    return YES;
}
- (void)textView:(QMUITextView *)textView didPreventTextChangeInRange:(NSRange)range replacementText:(NSString *)replacementText {
    [QMUITips showWithText:[NSString stringWithFormat:@"文字不能超过 %@ 个字符", @(textView.maximumTextLength)] inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:2.0];
}

-(CNLiveShareView *)shareView {
    if (!_shareView) {
        _shareView = [[CNLiveShareView alloc]init];
        _shareView.hidden = YES;
        _shareView.backgroundColor = UIColorMake(243, 243, 246);
    }
    return _shareView;
}

-(QMUITextView *)titleTextView{
    if (_titleTextView == nil) {
        _titleTextView = [[QMUITextView alloc] init];
        _titleTextView.delegate = self;
        _titleTextView.placeholder = @"这一刻的想法...";
        _titleTextView.placeholderColor = UIColorMake(152, 152, 152);
        //        _titleTextView.autoResizable = YES;
        _titleTextView.font = UIFontCNMake(16);
        _titleTextView.maximumTextLength = 10000;
        [_titleTextView becomeFirstResponder];
        _titleTextView.tintColor = kGuangbiaoColor;
    }
    return _titleTextView;
}


@end
