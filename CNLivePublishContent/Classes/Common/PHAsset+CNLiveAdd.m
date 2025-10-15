//
//  PHAsset+CNLiveAdd.m
//  CNLivePublishContent
//
//  Created by 殷巧娟 on 2019/6/10.
//

#import "PHAsset+CNLiveAdd.h"

@implementation PHAsset (CNLiveAdd)
+(NSURL *)movieURL:(PHAsset*)asset {
    __block NSURL *url = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            url = urlAsset.URL;
            dispatch_semaphore_signal(semaphore);
        }];
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return url;
}
+ (NSString *)getVideoTime:(PHAsset *)asset{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[PHAsset movieURL:asset] options:opts];  // 初始化视频媒体文件
    NSInteger minute = 0, second = 0;
    NSString *timeStr;
    NSInteger time = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    //NSLog(@"movie duration : %d", second);
    
    if (time < 10) {
        timeStr = [NSString stringWithFormat:@"0:0%ld",time];
        
    }else if (time < 60 && time>=10) {
        timeStr = [NSString stringWithFormat:@"0:%ld",time];
    } else {
        minute = time / 60;
        second = time - (minute * 60);
        if (minute < 10) {
            if (second < 10) {
                timeStr = [NSString stringWithFormat:@"0%ld:0%ld",minute,second];
            }else {
                timeStr = [NSString stringWithFormat:@"0%ld:%ld",minute,second];
            }
        }else {
            if (second < 10) {
                timeStr = [NSString stringWithFormat:@"%ld:0%ld",minute,second];
            }else {
                timeStr = [NSString stringWithFormat:@"%ld:%ld",minute,second];
            }
        }
    }
    return timeStr;
}

+ (NSInteger)returnVideoTime:(PHAsset *)asset {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[PHAsset movieURL:asset] options:opts];  // 初始化视频媒
    return [[NSNumber numberWithFloat:CMTimeGetSeconds(urlAsset.duration)] integerValue];//时长
}

@end
