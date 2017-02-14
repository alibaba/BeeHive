/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BeeHive.h"

@interface BeeHive()

@property (nonatomic, strong) BHModuleManager *moduleManager;
@property (nonatomic, strong) BHServiceManager *serviceManager;

@end

@implementation BeeHive

#pragma mark - public

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id BHInstance = nil;
    
    dispatch_once(&p, ^{
        BHInstance = [[BeeHive alloc] init];
    });
    
    return BHInstance;
}

+ (void)registerDynamicModule:(Class)moduleClass
{
    [[BeeHive shareInstance].moduleManager registerDynamicModule:moduleClass];
}

- (id)createService:(Protocol *)proto;
{
    return [[BHServiceManager sharedManager] createService:proto];
}

- (void)registerService:(Protocol *)proto service:(Class)serviceClass
{
    [[BHServiceManager sharedManager] registerService:proto implClass:serviceClass];
}

- (void)triggerEvent:(BHModuleEventType)eventType
{
    [self.moduleManager triggerEvent:eventType];
}

- (void)tiggerCustomEvent:(NSInteger)eventType
{
    if(eventType < 1000) {
        return;
    }
    
    [self triggerEvent:eventType];
}

#pragma mark - Private

-(void)setContext:(BHContext *)context
{
    _context = context;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.serviceManager.enableException = self.enableException;
        [self.serviceManager loadServices];
        
        [self.moduleManager setupModules];
    });
}

- (BHModuleManager *)moduleManager
{
    if (!_moduleManager) {
        _moduleManager = [BHModuleManager new];
    }
    return _moduleManager;
}

- (BHServiceManager *)serviceManager
{
    if (!_serviceManager) {
        _serviceManager = [BHServiceManager new];
    }
    return _serviceManager;
}

@end
