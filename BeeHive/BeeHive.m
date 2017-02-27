/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BeeHive.h"
#import "BHServiceManager.h"


@interface BeeHive()

@property (nonatomic, strong) BHServiceManager *serviceManager;
@property (nonatomic, strong) BHModuleManager *moduleManager;

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

- (instancetype)init{
    self = [super init];
    if (self) {
        _serviceManager = [BHServiceManager new];
        _moduleManager = [BHModuleManager new];
    }
    return self;
}

- (void)registerDynamicModule:(Class)moduleClass
{
    [self.moduleManager registerDynamicModule:moduleClass];
}

- (id)createService:(Protocol *)proto;
{
    return [self.serviceManager createService:proto];
}

- (void)registerService:(Protocol *)proto service:(Class) serviceClass
{
    [self.serviceManager registerService:proto implClass:serviceClass];
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
    
    [self.moduleManager loadLocalModules];
    
    [self.moduleManager registedAnnotationModules];

    [self.moduleManager registedAllModules];
    
}

-(void)loadStaticServices
{
    self.serviceManager.enableException = self.enableException;
    
    [self.serviceManager registerLocalServices];
    
    [self.serviceManager registerAnnotationServices];
    
}
- (void)triggerEvent:(BHModuleEventType)eventType{
    [self.moduleManager triggerEvent:eventType];
}

- (void)tiggerCustomEvent:(NSInteger)eventType
{
    if(eventType < 1000) {
        return;
    }
    
    [self.moduleManager triggerEvent:eventType];
}

@end
