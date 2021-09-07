//
//  AppDelegate.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/6/7.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "AppDelegate.h"
#import "Notification.h"

@interface AppDelegate ()
{
    UIWindow * _window;
}
@end

@implementation AppDelegate

- (UIWindow *)window{
    return _window;
}

- (void)setWindow:(UIWindow *)window{
    _window = window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[[Notification alloc] init] requestNotificationAuthorization];
    // Override point for customization after application launch.
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
