//
//  CNLivePublishContentLayout.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNLivePublishContentLayout : NSObject
-(CGFloat)conllectionViewHeight:(NSMutableArray *)photosArray assetArray:(NSMutableArray *)assetArray isSelectedVideo:(NSInteger)isSelectVideo;
@end

NS_ASSUME_NONNULL_END
