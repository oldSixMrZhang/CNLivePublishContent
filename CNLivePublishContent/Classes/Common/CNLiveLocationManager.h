//
//  CNLiveLocationManager.h
//  LocationManager
//
//  Created by 梁星国 on 2018/9/19.
//  Copyright © 2018年 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CNLivePlacemark;

typedef void (^LocationCoordinate2DBlock) (CLLocationDegrees latitude, CLLocationDegrees longitude);//经纬度信息
typedef void (^CNLivePlacemarkBlock) (CNLivePlacemark *placemark);//地理信息

typedef void (^Failure)(id error);//失败

@interface CNLiveLocationManager : NSObject

/**
 释放单例
 */
+(void)attempDealloc;

/**
 定位回调

 @param coordinate2DBlock 经纬度
 @param failure 无信息或有错误
 */
+ (void)getLocation:(LocationCoordinate2DBlock)coordinate2DBlock failure:(Failure)failure;

/**
 定位停止
 */
+ (void)stop;

/**
 是否启用定位服务

 @return 是否启用定位服务
 */
+ (BOOL)locationServicesEnabled;

/**
 反向地理编码获取地址信息

 @param latitude 纬度
 @param longitude 经度
 @param placemarkBlock 地理信息
 @param failure 无信息或有错误
 */
+ (void)getLocationWithLatitude:(NSString *)latitude longitude:(NSString *)longitude placemarkBlock:(CNLivePlacemarkBlock)placemarkBlock failure:(Failure)failure;

/**
 反向地理编码获取地址信息

 @param coordinate2D 经纬度
 @param placemarkBlock 地理信息
 @param failure 无信息或有错误
 */
+ (void)getLocationWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D PlacemarkBlock:(CNLivePlacemarkBlock)placemarkBlock failure:(Failure)failure;

/**
 地理编码获取经纬度

 @param address 地址
 @param coordinate2DBlock 经纬度信息
 @param failure 无信息或有错误
 */
+ (void)getLocationWithAddress:(NSString *)address coordinate2DBlock:(LocationCoordinate2DBlock)coordinate2DBlock failure:(Failure)failure;

@end


/** 只限制中国使用,其他国家使用高德优先 */
@interface CNLivePlacemark: NSObject

/** id */
@property (nonatomic, assign) int placemarkId;
/** 类型 */
@property (nonatomic, copy) NSString *type;
/** 国家 */
@property (nonatomic, copy) NSString *country;
/** 省 */
@property (nonatomic, copy) NSString *province;
/** 城市 */
@property (nonatomic, copy) NSString *city;
/** 县(区) */
@property (nonatomic, copy) NSString *county;
/** 地址 */
@property (nonatomic, copy) NSString *address;

/** 初始化 */
+ (CNLivePlacemark *)initWithCLPlacemark:(CLPlacemark *)placemark;
/** 取得省市 */
- (NSString *)getProvinceAndCity;

@end
