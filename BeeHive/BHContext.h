/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "BHServiceProtocol.h"
#import "BHConfig.h"
#import "BHAppDelegate.h"

typedef enum
{
    BHEnvironmentDev = 0,
    BHEnvironmentTest,
    BHEnvironmentStage,
    BHEnvironmentProd
}BHEnvironmentType;


@interface BHContext : NSObject

//global env
@property(nonatomic, assign) BHEnvironmentType env;

//global config
@property(nonatomic, strong) BHConfig *config;

//application appkey
@property(nonatomic, strong) NSString *appkey;


@property(nonatomic, strong) UIApplication *application;

@property(nonatomic, strong) NSDictionary *launchOptions;

@property(nonatomic, strong) NSString *moduleConfigName;

@property(nonatomic, strong) NSString *serviceConfigName;

@property(nonatomic, strong) NSMutableDictionary *modulesByName;

@property(nonatomic, strong) NSMutableDictionary *servicesByName;

//3D-Touch model
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 80400
@property (nonatomic, strong) BHShortcutItem *touchShortcutItem;
#endif

//OpenURL model
@property (nonatomic, strong) BHOpenURLItem *openURLItem;

//Notifications Remote or Local
@property (nonatomic, strong) BHNotificationsItem *notificationsItem;

//user Activity Model
@property (nonatomic, strong) BHUserActivityItem *userActivityItem;

+(instancetype) shareInstance;


@end
