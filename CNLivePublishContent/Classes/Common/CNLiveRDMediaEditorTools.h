//
//  CNLiveRDMediaEditorTools.h
//  CNLiveRDShortVideoSDK
//
//  Created by iOS on 2017/7/28.
//  Copyright © 2017年 zhulin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNLiveRDMediaEditorTools : NSObject

//获取真实时间
+ (void)getRealTimeString:(void(^)(NSString *timeString, NSDate *date))realTime;

//获取MD5
+ (NSString*)rd_getFileMD5WithPath:(NSString*)path;

@end
