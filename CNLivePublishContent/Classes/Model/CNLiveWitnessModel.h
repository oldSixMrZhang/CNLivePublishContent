//
//  CNLiveWitnessModel.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNLiveWitnessModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *videoimage;
@property (assign, nonatomic) BOOL isEdit;
@property (nonatomic, copy) NSString *videoType;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, copy) NSString *timeLength;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSInteger mutileCategory;
@property (nonatomic, strong) NSArray *tagArray;
@property (nonatomic, copy) NSString *localIdentifier;// 获取资源Id的路径
@property (nonatomic, copy) NSString *shareUrl; //播放的路径
@property (nonatomic, assign) NSInteger showTagId;
@end

NS_ASSUME_NONNULL_END
