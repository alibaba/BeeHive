/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif


@interface BHAppDelegate : UIResponder <UIApplicationDelegate>

@end

typedef void (^BHNotificationResultHandler)(UIBackgroundFetchResult);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
typedef void (^BHNotificationPresentationOptionsHandler)(UNNotificationPresentationOptions options);
typedef void (^BHNotificationCompletionHandler)();
#endif

@interface BHNotificationsItem : NSObject

@property (nonatomic, strong) NSError *notificationsError;
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, copy) BHNotificationResultHandler notificationResultHander;
@property (nonatomic, strong) UILocalNotification *localNotification;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, strong) UNNotification *notification;
@property (nonatomic, strong) UNNotificationResponse *notificationResponse;
@property (nonatomic, copy) BHNotificationPresentationOptionsHandler notificationPresentationOptionsHandler;
@property (nonatomic, copy) BHNotificationCompletionHandler notificationCompletionHandler;
@property (nonatomic, strong) UNUserNotificationCenter *center;
#endif

@end

@interface BHOpenURLItem : NSObject

@property (nonatomic, strong) NSURL *openURL;
@property (nonatomic, copy) NSString *sourceApplication;
@property (nonatomic, strong) id annotation;
@property (nonatomic, strong) NSDictionary *options;

@end

typedef void (^BHShortcutCompletionHandler)(BOOL);

@interface BHShortcutItem : NSObject

#if __IPHONE_OS_VERSION_MAX_ALLOWED > 80400
@property(nonatomic, strong) UIApplicationShortcutItem *shortcutItem;
@property(nonatomic, copy) BHShortcutCompletionHandler scompletionHandler;
#endif

@end


typedef void (^BHUserActivityRestorationHandler)(NSArray *);

@interface BHUserActivityItem : NSObject

@property (nonatomic, copy) NSString *userActivityType;
@property (nonatomic, strong) NSUserActivity *userActivity;
@property (nonatomic, strong) NSError *userActivityError;
@property (nonatomic, copy) BHUserActivityRestorationHandler restorationHandler;

@end

typedef void (^BHWatchReplyHandler)(NSDictionary *replyInfo);

@interface BHWatchItem : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, copy) BHWatchReplyHandler replyHandler;

@end


