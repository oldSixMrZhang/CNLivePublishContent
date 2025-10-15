//
//  CNLiveRDMediaEditorTools.m
//  CNLiveRDShortVideoSDK
//
//  Created by iOS on 2017/7/28.
//  Copyright © 2017年 zhulin. All rights reserved.
//

#import "CNLiveRDMediaEditorTools.h"
#import "CommonCrypto/CommonDigest.h"
#import <UIKit/UIKit.h>
#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation CNLiveRDMediaEditorTools


#pragma mark -
#pragma mark - 真实时间
+ (void)getRealTimeString:(void (^)(NSString *, NSDate *))realTime
{
    NSDate *curDate = [NSDate date];
    NSInteger time = [curDate timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%ld", (long)time];
    dispatch_async(dispatch_get_main_queue(), ^{
        realTime(timeString, curDate);
    });
}

#pragma mark -
#pragma mark - MD5
+ (NSString *)rd_getFileMD5WithPath:(NSString*)path
{
    return (__bridge_transfer NSString *)RDFileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef RDFileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

+ (NSString *)urlEncodeUsingEncodingString:(NSString *)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

#pragma mark -
#pragma mark - uuid
+ (NSString *)uidForStat:(NSString *)date {
    
    NSString *uid = @"";
    
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    
    if ([defauts objectForKey:@"kCNLiveUserDefaultsUIDKey"]) {
        uid = [[defauts objectForKey:@"kCNLiveUserDefaultsUIDKey"] copy];
        return uid;
    } else {
        
        NSString *idfv = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uid = [NSString stringWithFormat:@"%@_%@", idfv, date];
        
        [defauts setObject:uid forKey:@"kCNLiveUserDefaultsUIDKey"];
        [defauts synchronize];
    }
    
    return uid;
}


@end
