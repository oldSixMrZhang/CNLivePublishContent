//
//  CNLivePublishContentTagCell.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import <QMUIKit/QMUIKit.h>
#import "CNLiveWitnessModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TagBtnClickedBlock)(NSString *tagName, NSInteger tagId,NSArray *tagArray,NSInteger showTagId);
typedef void(^ShowBtnClickedBlock)(void);
@interface CNLivePublishContentTagCell : QMUITableViewCell
@property (nonatomic, strong) NSArray *tagArray;
@property (nonatomic, copy) TagBtnClickedBlock tagBtnBlock;
@property (nonatomic, strong) CNLiveWitnessModel *witnessModel;
@property (nonatomic, copy) ShowBtnClickedBlock showBtnBlock;
-(void)setSelectedBtn:(NSInteger)idx;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, assign) NSInteger showTagId;
@end

NS_ASSUME_NONNULL_END
