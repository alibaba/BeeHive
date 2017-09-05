/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "BHAnnotation.h"
@class BHContext;
@class BeeHive;

#define BH_EXPORT_MODULE(isAsync) \
+ (void)load { [BeeHive registerDynamicModule:[self class]]; } \
-(BOOL)async { return [[NSString stringWithUTF8String:#isAsync] boolValue];}


@protocol BHModuleProtocol <NSObject>


@optional

//如果不去设置Level默认是Normal
//basicModuleLevel不去实现默认Normal
- (void)basicModuleLevel;
//越大越优先
- (NSInteger)modulePriority;

- (BOOL)async;

- (void)modSetUp:(BHContext *)context;

- (void)modInit:(BHContext *)context;

- (void)modSplash:(BHContext *)context;

- (void)modQuickAction:(BHContext *)context;

- (void)modTearDown:(BHContext *)context;

- (void)modWillResignActive:(BHContext *)context;

- (void)modDidEnterBackground:(BHContext *)context;

- (void)modWillEnterForeground:(BHContext *)context;

- (void)modDidBecomeActive:(BHContext *)context;

- (void)modWillTerminate:(BHContext *)context;

- (void)modUnmount:(BHContext *)context;

- (void)modOpenURL:(BHContext *)context;

- (void)modDidReceiveMemoryWaring:(BHContext *)context;

- (void)modDidFailToRegisterForRemoteNotifications:(BHContext *)context;

- (void)modDidRegisterForRemoteNotifications:(BHContext *)context;

- (void)modDidReceiveRemoteNotification:(BHContext *)context;

- (void)modDidReceiveLocalNotification:(BHContext *)context;

- (void)modWillPresentNotification:(BHContext *)context;

- (void)modDidReceiveNotificationResponse:(BHContext *)context;

- (void)modWillContinueUserActivity:(BHContext *)context;

- (void)modContinueUserActivity:(BHContext *)context;

- (void)modDidFailToContinueUserActivity:(BHContext *)context;

- (void)modDidUpdateContinueUserActivity:(BHContext *)context;

- (void)modHandleWatchKitExtensionRequest:(BHContext *)context;

- (void)modDidCustomEvent:(BHContext *)context;
@end
