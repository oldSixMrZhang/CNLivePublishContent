//
//  CNLivePublishContentLayout.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/6.
//

#import "CNLivePublishContentLayout.h"
#import "CNLiveDefinesHeader.h"
@implementation CNLivePublishContentLayout
-(CGFloat)conllectionViewHeight:(NSMutableArray *)photosArray assetArray:(NSMutableArray *)assetArray isSelectedVideo:(NSInteger)isSelectVideo{
    
    CGFloat margin = 4;
    CGFloat itemWH = (KScreenWidth - 2 * margin - 4) / 3 - margin;
    CGFloat collHeight = 0;
    NSInteger column = 3;// 列
    NSInteger row = 0;//行
    if ((photosArray.count + isSelectVideo) % column <= 0) {
        row = (photosArray.count + isSelectVideo) / column;
    }else {
        row = (photosArray.count + isSelectVideo) / column + 1;
    }
    collHeight = 2 * margin + (row - 1) * 8 + row * itemWH;
    return collHeight;
}
@end
