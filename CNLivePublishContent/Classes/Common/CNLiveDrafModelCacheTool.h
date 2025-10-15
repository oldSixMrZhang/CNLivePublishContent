//
//  CNLiveDrafModelCacheTool.h
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import <Foundation/Foundation.h>
#import "CNLiveDefinesHeader.h"
#import <YYKit/YYKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CNLiveDrafModelCacheTool : NSObject
SINGLETON_FOR_HEADER(CNLiveDrafModelCacheTool)
/**
 获取缓存器
 */
-(YYCache *)selectYYCache;
/**
 重新初始化缓存
 */
- (void)resetCache;
@end

NS_ASSUME_NONNULL_END
