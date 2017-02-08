/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BeeHive.h"


//BootLoader

@interface BeeHive()

@end


@implementation BeeHive

#pragma mark - public

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id BHInstance = nil;
    
    dispatch_once(&p, ^{
        BHInstance = [[self alloc] init];
    });
    
    return BHInstance;
}

+ (void)registerDynamicModule:(Class)moduleClass
{
    [[BHModuleManager sharedManager] registerDynamicModule:moduleClass];
}

- (id)createService:(Protocol *)proto;
{
    return [[BHServiceManager sharedManager] createService:proto];
}

- (void)registerService:(Protocol *)proto service:(Class) serviceClass
{

    [[BHServiceManager sharedManager] registerService:proto implClass:serviceClass];
}

#pragma mark - Private

-(void)setContext:(BHContext *)context
{
    _context = context;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadStaticServices];
        [self loadStaticModules];
    });
}


- (void)loadStaticModules
{
    [[BHModuleManager sharedManager] setWholeContext:self.context];
    
    [[BHModuleManager sharedManager] loadLocalModules];
    
    [[BHModuleManager sharedManager] registedAnnotationModules];

    [[BHModuleManager sharedManager] registedAllModules];
    
}

-(void)loadStaticServices
{
    [BHServiceManager sharedManager].enableException = self.enableException;
    
    [[BHServiceManager sharedManager] setWholeContext:self.context];
    
    [[BHServiceManager sharedManager] registerLocalServices];
    
    [[BHServiceManager sharedManager] registerAnnotationServices];
    
}
- (void)tiggerCustomEvent:(NSInteger)eventType{
    if(eventType<1000)
    return;
    [[BHModuleManager sharedManager] triggerEvent:eventType];
}

@end
