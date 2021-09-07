//
//  Notification.m
//  ClickforceWT
//
//  Created by Eric Chen on 2021/8/6.
//  Copyright © 2021 Eric Chen. All rights reserved.
//

#import "Notification.h"

@implementation Notification
- (instancetype)init
{
    self = [super init];
    if (self) {
        center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
//        self.locationManager = [[CLLocationManager alloc] init];
//        [self requestLocation];
        [self setParamsValue];
    }
    return self;
}

- (void)setParamsValue{
    _nextWorkInRequest = @"nextWorkInRequest";
    _nowWorkInRequest = @"nowWorkInRequest";
    _nowWorkOutRequest = @"nowWorkOutRequest";
    _dateRequest = @"dateRequest";
    _date5Request = @"date5Request";
    _date10Request = @"date10Request";
}

- (id) initWithAuthorization{
    if (self) {
        center = [UNUserNotificationCenter currentNotificationCenter];
        self.locationManager = [[CLLocationManager alloc] init];
//        [self requestLocation];
    }
    return self;
}

- (void) requestlocation{
    if (self.locationManager != nil) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestWhenInUseAuthorization];
//        if ([CLLocationManager locationServicesEnabled]) {
//            NSLog(@"%d",CLLocationManager.authorizationStatus);
//            [self.locationManager startUpdatingLocation];
//            NSLog(@"Location request!");
//        }

    }

//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.allowsBackgroundLocationUpdates = YES;
//    [self.locationManager requestWhenInUseAuthorization];
//    if ([CLLocationManager locationServicesEnabled]) {
//        NSLog(@"%d",CLLocationManager.authorizationStatus);
//        [self.locationManager startUpdatingLocation];
//    }
//
//    NSLog(@"Location request!");
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    NSLog(@"%s",__FUNCTION__);
//    //取得當前位置
//        CLLocation *currentLocation = [locations lastObject];
//        if(currentLocation != nil){
//            NSLog(@"%@ - %@",[NSString stringWithFormat:@"%.2f",currentLocation.coordinate.latitude],[NSString stringWithFormat:@"%.2f",currentLocation.coordinate.longitude]);
//            //停止偵測
//            [self.locationManager stopUpdatingLocation];
//        }
//}
//- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager{
//    NSLog(@"%s",__FUNCTION__);
//}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"%s---%d", __FUNCTION__,status);
}

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"%s",__FUNCTION__);
//}

- (void)requestNotificationAuthorization{
    NSLog(@"%s",__FUNCTION__);
    if (center != nil) {
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // Enable or disable features based on authorization.
            if (granted == YES) {
                NSLog(@"通知接受授權Ｖ");
            }
            else {
                NSLog(@"通知拒絕授權Ｘ");
            }
        }];
     
        // 獲取當前的通知設置
//        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//            NSLog(@"Notification Settings: %@", settings);
//        }];
    }
}

- (void)addNotificationWhitCalendar:(NSDateComponents *)date identifier:(NSString*)content_identifier tittle:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body{
    if (center != nil) {
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                             triggerWithDateMatchingComponents:date repeats:NO];
        
        //建立推播請求
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:content_identifier
                                                                              content:[self setNotificationContent:content_title
                                                                                                         subtittle:content_subtittle
                                                                                                              body:content_body]
                                                                              trigger:trigger];
        
        // 新增推播成功後的處理
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"Calendar Notification done!");
            }
        }];
    }
    
}

- (void)addNotificationWhitTimeInterval:(double)time tittle:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body{
    if (center != nil) {
        
        // 在 time 後推送本地推播
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        
        //建立推播請求
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"timeRequest"
                                                                              content:[self setNotificationContent:content_title
                                                                                                         subtittle:content_subtittle
                                                                                                              body:content_body]
                                                                              trigger:trigger];
        
        // 新增推播成功後的處理
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Time Interval Notification done!");
        }];
    }
}

- (void)addNotificationWithLocation:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body identifier:(NSString*)content_identifier{
    if (center != nil) {
        //域動經緯度 25.052051178686426, 121.54596848792922
        //25.041772564966443, 121.54869844473211 離開
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(25.052051178686426, 121.54596848792922);
        CLCircularRegion* region;
        UNLocationNotificationTrigger* trigger;
        if ([content_identifier isEqualToString:_nowWorkInRequest] ) {
            region = [[CLCircularRegion alloc] initWithCenter:location  radius:5.0 identifier:content_identifier];
            region.notifyOnEntry = YES;
            region.notifyOnExit = NO;
            trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:NO];
        } else if ([content_identifier isEqualToString:_nowWorkOutRequest]){
            region = [[CLCircularRegion alloc] initWithCenter:location  radius:500.0 identifier:content_identifier];
            region.notifyOnEntry = NO;
            region.notifyOnExit = YES;
            trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
        }

        
        
        //建立推播請求
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:content_identifier
                                                                              content:[self setNotificationContent:content_title
                                                                                                         subtittle:content_subtittle
                                                                                                              body:content_body]
                                                                              trigger:trigger];
        
        // 新增推播成功後的處理
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Location Notification done!");
        }];
    }
    
    
}

- (UNMutableNotificationContent *) setNotificationContent:(NSString*)content_title subtittle:(NSString*)content_subtittle body:(NSString*)content_body{
    //建立待通知內容的 UNMutableNotificationContent 對象
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:content_title arguments:nil];
    if(![content_subtittle isEqualToString:@""]) content.subtitle = [NSString localizedUserNotificationStringForKey:content_subtittle arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:content_body arguments:nil];
//        content.sound = [UNNotificationSound defaultSound];
    
    return content;
}

- (void)getAllNotification{
    if (nil != center) {
        //判斷待通知的訊息
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            if ([notifications count] > 0) {
                NSLog(@"getPendingNotificationRequestsWithCompletionHandler --- Count: %lu",(unsigned long)[notifications count]);
                for (UNNotification *obj in notifications) {
                    NSLog(@"getPendingNotificationRequestsWithCompletionHandler --- %@", obj);
                }
                
            } else {
                NSLog(@"getPendingNotificationRequestsWithCompletionHandler --- NO notification");
            }
            
        }];
        //判斷通知中心上已顯示/已通知的訊息
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            if ([notifications count] > 0) {
                NSLog(@"getDeliveredNotificationsWithCompletionHandler --- Count: %lu",(unsigned long)[notifications count]);
                for (UNNotification *obj in notifications) {
                    NSLog(@"getDeliveredNotificationsWithCompletionHandler --- %@", obj);
                }
            } else {
                NSLog(@"getDeliveredNotificationsWithCompletionHandler --- NO notification");
            }
        }];
    }
}

- (void)removeAllNotification{
    if (nil != center) {
        NSLog(@"Notification-RemoveAll");
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
//        //判斷待通知的訊息
//        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
//            if ([notifications count] > 0) {
////                NSLog(@"getPendingNotificationRequestsWithCompletionHandler --- Count: %lu",(unsigned long)[notifications count]);
////                for (UNNotification *obj in notifications) {
////                    NSLog(@"getPendingNotificationRequestsWithCompletionHandler --- %@", obj);
////                }
//                [center removeAllPendingNotificationRequests];//刪除所有待通知內容
//            } else {
//                NSLog(@"getPendingNotificationRequestsWithCompletionHandler --- NO notification");
//            }
//            
//        }];
//        //判斷通知中心上已顯示/已通知的訊息
//        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
//            if ([notifications count] > 0) {
////                NSLog(@"getDeliveredNotificationsWithCompletionHandler --- Count: %lu",(unsigned long)[notifications count]);
////                for (UNNotification *obj in notifications) {
////                    NSLog(@"getDeliveredNotificationsWithCompletionHandler --- %@", obj);
////                }
//                [center removeAllDeliveredNotifications];//刪除所有已通知內容
//            } else {
//                NSLog(@"getDeliveredNotificationsWithCompletionHandler --- NO notification");
//            }
//        }];
        
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    NSLog(@"%s",__FUNCTION__);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"userNotificationCenter ----> %@",notification);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    NSLog(@"didReceiveNotificationResponse ---> %@",response);
}

@end
