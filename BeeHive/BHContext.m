/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BHContext.h"


@interface BHContext()



@end

@implementation BHContext

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.modulesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.servicesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.moduleConfigName = @"BeeHive.bundle/BeeHive";
        self.serviceConfigName = @"BeeHive.bundle/BHService";
      
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 80400
        self.touchShortcutItem = [BHShortcutItem new];
#endif

        self.openURLItem = [BHOpenURLItem new];
        self.notificationsItem = [BHNotificationsItem new];
        self.userActivityItem = [BHUserActivityItem new];
    }

    return self;
}

+(instancetype) shareInstance
{
    static dispatch_once_t p;
    static id BHInstance = nil;
    
    dispatch_once(&p, ^{
        BHInstance = [[[self class] alloc] init];
        if ([BHInstance isKindOfClass:[BHContext class]]) {
            ((BHContext *) BHInstance).config = [BHConfig shareInstance];
        }
    });
    
    return BHInstance;
}


@end
