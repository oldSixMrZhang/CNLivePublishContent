//
//  CNLivePublishContentController.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import "CNCommonTableViewController.h"
#import "CNLivePublishContentCell.h"
@class CNLiveWitnessModel;
NS_ASSUME_NONNULL_BEGIN
@protocol WitnessRefreshDataDelegate <NSObject>

-(void)setRefreshWitnessData;
@end
@interface CNLivePublishContentController : CNCommonTableViewController
@property (nonatomic, assign) BOOL isShare;
- (void)photoFinishselectedPhotos:(NSMutableArray *)selectedPhotos selectedAssets:(NSMutableArray *)selectedAssets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
@property (nonatomic, copy) NSString *publishType; // 发布的type类型
@property (nonatomic, assign) CNLivePublishContentTypes publishContentType;
@property (nonatomic, copy) NSString *videoType; // 上面的视频类型
@property (nonatomic, assign) NSInteger multipleCategory; //
@property (nonatomic, copy) NSString *path;// 上冰雪等的上传路径
@property (nonatomic, strong) CNLiveWitnessModel *witnessModel;
-(void)setShareTitle:(NSString *)shareTitle image:(id)image des:(NSString*)des shreUrl:(NSString *)shareUrl;
@property (nonatomic, weak) id <WitnessRefreshDataDelegate> delegate;
@property (nonatomic, assign) BOOL isWitnessH5;
@property (nonatomic, strong) NSArray *tagArray;
@end

NS_ASSUME_NONNULL_END
