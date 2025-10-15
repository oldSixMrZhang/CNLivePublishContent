//
//  CNLivePublishContentCell.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import <QMUIKit/QMUIKit.h>
@class CNLiveShareView;
@class CNLiveWitnessModel;
@protocol CellSelectDelegate <NSObject>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemNsIndexPath:(NSIndexPath *)indexPath;
-(void)deledteBtnClick:(NSMutableArray *)selectedPhotos selectedAssets:(NSMutableArray *)selectedAssets;
@end
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, CNLivePublishCellType) {
    CNLivePublishCellTypeHeader  = 20      ,//上面的选择圈子的
    CNLivePublishCellTypeMiddle  = 21       ,//中间的那个textView
    CNLivePublishCellTypeBottom  = 22       ,//下面的九宫格
    CNLivePublishCellTypeTag     = 23       ,// 下面的tag标签
};

typedef NS_ENUM(NSInteger,CNLivePublishContentTypes) {//发布朋友圈的类型
    CNLivePsublishWitnessContentTypeText          = 0,//纯文字
    CNLivePublishWitnessContentTypePicture          ,//图片
    CNLivePublishWitnessContentTypeVideo            ,//视频
    CNLivePublishWitnessContentTypeShare            ,//分享
    CNLivePublishWitnessContentTypeOther            ,// 其他
};
@protocol TextViewDidChanegDelegate <NSObject>

-(void)textViewDidChangeTextView:(UITextView *)textView;
-(void)shouldBeginEditingTextView:(UITextView *)textView;
@end
@interface CNLivePublishContentCell : QMUITableViewCell
@property (nonatomic, copy) NSString *publishType;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, assign) CNLivePublishCellType publishCellType;
@property (nonatomic, assign) CNLivePublishContentTypes publishContentType;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, strong) id shareImage;
@property (nonatomic, copy) NSString *shareDes;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, weak) id<TextViewDidChanegDelegate> delegate;
@property (nonatomic, strong) CNLiveShareView *shareView;
@property (nonatomic, strong) CNLiveWitnessModel *witnessModel;
@property (nonatomic, strong) QMUITextView *titleTextView;
@property (nonatomic, weak)id <CellSelectDelegate> cellSelectDelegate;//点击cell实现方法
-(void)updateCollectionViewWithAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

NS_ASSUME_NONNULL_END
