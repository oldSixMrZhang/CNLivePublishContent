
//
//  CNLiveLocationManager.m
//  LocationManager
//
//  Created by 梁星国 on 2018/9/19.
//  Copyright © 2018年 cnlive. All rights reserved.
//

#import "CNLiveLocationManager.h"

@interface CNLiveLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, copy) LocationCoordinate2DBlock coordinate2DBlock;
@property (nonatomic, copy) Failure failure;


@end

@implementation CNLiveLocationManager

static CNLiveLocationManager *_manager = nil;
/// 单例初始化
+ (CNLiveLocationManager *)instance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[CNLiveLocationManager alloc] init];
    });
    return _manager;
}

/// 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;//精度
        _locationManager.distanceFilter = 10;
        
        // 兼容iOS8.0版本
        /* Info.plist里面加上2项中的一项
         NSLocationAlwaysUsageDescription      String YES
         NSLocationWhenInUseUsageDescription   String YES
         */
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            // iOS8.0以上，使用应用程序期间允许访问位置数据
            [_locationManager requestWhenInUseAuthorization];
            // iOS8.0以上，始终允许访问位置信息
            //            [_locationManager requestAlwaysAuthorization];
        }
        
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

/// 释放
+(void)attempDealloc {
    
    _manager = nil;
}

#pragma mark - 定位方法
/// 定位回调实现
- (void)getLocation:(LocationCoordinate2DBlock)coordinate2DBlock failure:(Failure)failure {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return;
    }
    _coordinate2DBlock = coordinate2DBlock;
    _failure = failure;
    // 停止上一次定位
    [_locationManager stopUpdatingLocation];
    // 开始新一次定位
    [_locationManager startUpdatingLocation];
}
/// 停止定位实现
- (void)stop {
    [_locationManager stopUpdatingLocation];
}

/// 反向坐标获取地址信息实现
- (void)getLocationWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D placemarkBlock:(CNLivePlacemarkBlock)placemarkBlock failure:(Failure)failure{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = placemarks.lastObject;
                CNLivePlacemark *livePlacemark = [CNLivePlacemark initWithCLPlacemark:placemark];
                if (placemarkBlock) {
                    placemarkBlock(livePlacemark);
                }
            }else {
                if (failure) {
                    failure(error);
                }
            }
        }else{
            if (failure) {
                failure(error);
            }
        }
    }];
}

/// 地理编码获取经纬度实现
- (void)getLocationWithAddress:(NSString *)address coordinate2DBlock:(LocationCoordinate2DBlock)coordinate2DBlock failure:(Failure)failure {
    [_geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = placemarks.lastObject;
                if (coordinate2DBlock) {
                    coordinate2DBlock(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
                }
            }else {
                if (failure) {
                    failure(error);
                }
            }
        }else{
            if (failure) {
                failure(error);
            }
        }
    }];
}

#pragma mark -
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    CLLocationDegrees lat = location.coordinate.latitude;
    CLLocationDegrees lng = location.coordinate.longitude;
    NSLog(@"当前更新位置: 纬度: (%lf), 经度: (%lf)", lat, lng);
    
    if (_coordinate2DBlock) {
        _coordinate2DBlock(lat, lng);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    } else if (error.code == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
    if (_failure) {
        _failure(error);
    }
    
}

#pragma mark - 定位实例方法
/// 定位回调
+ (void)getLocation:(LocationCoordinate2DBlock)coordinate2DBlock failure:(Failure)failure{
    [[CNLiveLocationManager instance] getLocation:coordinate2DBlock failure:failure];
}

/// 停止定位
+ (void)stop{
    [[CNLiveLocationManager instance] stop];
}

/// 是否启用定位服务
+ (BOOL)locationServicesEnabled{
    return [CLLocationManager locationServicesEnabled];
}

/// 反向地理编码获取地址信息
+ (void)getLocationWithLatitude:(NSString *)latitude longitude:(NSString *)longitude placemarkBlock:(CNLivePlacemarkBlock)placemarkBlock failure:(Failure)failure{
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    [[CNLiveLocationManager instance] getLocationWithCoordinate2D:coordinate2D placemarkBlock:placemarkBlock failure:failure];
    
}

/// 反向地理编码获取地址信息
+ (void)getLocationWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D PlacemarkBlock:(CNLivePlacemarkBlock)placemarkBlock failure:(Failure)failure{
    [[CNLiveLocationManager instance] getLocationWithCoordinate2D:coordinate2D placemarkBlock:placemarkBlock failure:failure];
}

/// 地理编码获取经纬度
+ (void)getLocationWithAddress:(NSString *)address coordinate2DBlock:(LocationCoordinate2DBlock)coordinate2DBlock failure:(Failure)failure{
    [[CNLiveLocationManager instance] getLocationWithAddress:address coordinate2DBlock:coordinate2DBlock failure:failure];
}


@end

@implementation CNLivePlacemark

- (id)mutableCopyWithZone:(NSZone *)zone {
    CNLivePlacemark *copy = [[[self class] allocWithZone:zone] init];
    _country = [self.country mutableCopy];
    _province = [self.province mutableCopy];
    _city = [self.city mutableCopy];
    _county = [self.county mutableCopy];
    _address = [self.address mutableCopy];
    _placemarkId = self.placemarkId;
    _type = [self.type mutableCopy];
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    CNLivePlacemark *copy = [[[self class] allocWithZone:zone] init];
    _country = [self.country copy];
    _province = [self.province copy];
    _city = [self.city copy];
    _county = [self.county copy];
    _address = [self.address copy];
    _placemarkId = self.placemarkId;
    _type = [self.type copy];
    return copy;
}

- (NSString *)city {
    NSString *cityName = _city;
    if ([cityName hasSuffix:@"市辖区"]) {
        cityName = [cityName substringToIndex:[cityName length] - 3];
    }
    if ([cityName hasSuffix:@"市"]) {
//        cityName = [cityName substringToIndex:[cityName length]];
        cityName = cityName;
    }
    if ([cityName isEqualToString:@"香港特別行政區"] || [cityName isEqualToString:@"香港特别行政区"]) {
        cityName = @"香港";
    }
    if ([cityName isEqualToString:@"澳門特別行政區"] || [cityName isEqualToString:@"澳门特别行政区"]) {
        cityName = @"澳门";
    }
    return cityName;
}

- (NSString *)province {
    NSString *provinceName = _province;
    if ([provinceName hasSuffix:@"省"]) {
        provinceName = [provinceName substringToIndex:[provinceName length] - 1];
    } else if ([provinceName hasSuffix:@"市"]) {
//        provinceName = [provinceName substringToIndex:[provinceName length] - 1];
        provinceName = provinceName;
    }
    return provinceName;
}

/// 实例化
+ (CNLivePlacemark *)initWithCLPlacemark:(CLPlacemark *)placemark {
    CNLivePlacemark *mark = [[CNLivePlacemark alloc] init];
    mark.country = placemark.country ? placemark.country : @"";
    mark.province = placemark.administrativeArea ? placemark.administrativeArea : @"";
    mark.city = placemark.locality ? placemark.locality : mark.province;
    mark.county = placemark.subLocality ? placemark.subLocality : @"";
    NSString *formatAddress = [NSString stringWithFormat:@"%@%@", placemark.thoroughfare ? placemark.thoroughfare : @"",
                               placemark.subThoroughfare ? placemark.subThoroughfare:@""];
    mark.address = formatAddress;
    return mark;
}

/// 取得省市
- (NSString *)getProvinceAndCity {
    NSString *provinceName = _province ? : @"";
    NSString *cityName = _city ? : @"";
    if ([self.city isEqualToString:self.province]) {
        provinceName = @"";
    }
    if ([cityName hasSuffix:@"市辖区"]) {
        cityName = [cityName substringToIndex:[cityName length] - 3];
    }
    if ([cityName isEqualToString:@"香港特別行政區"] || [cityName isEqualToString:@"香港特别行政区"]) {
        cityName = @"香港";
    }
    if ([cityName isEqualToString:@"澳門特別行政區"] || [cityName isEqualToString:@"澳门特别行政区"]) {
        cityName = @"澳门";
    }
    return [provinceName stringByAppendingString:cityName];
}



@end

