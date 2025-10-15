//
//  CNLiveDrafModelCacheTool.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import "CNLiveDrafModelCacheTool.h"
#import "CNUserInfoManager.h"
@implementation CNLiveDrafModelCacheTool

static YYCache *yyCache = nil;
SINGLETON_FOR_CLASS(CNLiveDrafModelCacheTool)
- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/imageAndvideo_4", CNUserShareModel.uid]];
        yyCache = [YYCache cacheWithPath:filePath];
        yyCache.diskCache.customFileNameBlock = ^NSString * _Nonnull(NSString * _Nonnull key) {
            return filePath;
        };
    }
    return self;
}
- (void)resetCache
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/imageAndvideo_4",CNUserShareModel.uid]];
    
    yyCache = [YYCache cacheWithPath:filePath];
    
    yyCache.diskCache.customFileNameBlock = ^NSString * _Nonnull(NSString * _Nonnull key) {
        return filePath;
    };
}
-(YYCache *)selectYYCache
{
    return yyCache;
}
@end
