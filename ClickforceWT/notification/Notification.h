//
//  Notification.h
//  ClickforceWT
//
//  Created by Eric Chen on 2021/8/6.
//  Copyright © 2021 Eric Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN

@interface Notification : NSObject<UNUserNotificationCenterDelegate, CLLocationManagerDelegate>{
    UNUserNotificationCenter *center;
//    CLLocationManager *locationManager;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (readonly, nonatomic, weak) NSString *nextWorkInRequest;
@property (readonly, nonatomic, weak) NSString *nowWorkInRequest;
@property (readonly, nonatomic, weak) NSString *nowWorkOutRequest;
@property (readonly, nonatomic, weak) NSString *dateRequest;
@property (readonly, nonatomic, weak) NSString *date5Request;
@property (readonly, nonatomic, weak) NSString *date10Request;

- (id) initWithAuthorization;
- (void)requestNotificationAuthorization;
- (void)removeAllNotification;
- (void)getAllNotification;
//- (void)addNotificationWhitCalendar:(NSDateComponents *)date tittle:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body;
- (void)addNotificationWhitCalendar:(NSDateComponents *)date identifier:(NSString*)content_identifier tittle:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body;
- (void)addNotificationWhitTimeInterval:(double)time tittle:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body;
- (void)addNotificationWithLocation:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body identifier:(NSString*)content_identifier;
- (void) requestlocation;
@end

NS_ASSUME_NONNULL_END
