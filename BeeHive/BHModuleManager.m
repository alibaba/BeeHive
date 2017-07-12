/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BHModuleManager.h"
#import "BHModuleProtocol.h"
#import "BHContext.h"
#import "BHTimeProfiler.h"
#import "BHAnnotation.h"

#define kModuleArrayKey     @"moduleClasses"
#define kModuleInfoNameKey  @"moduleClass"
#define kModuleInfoLevelKey @"moduleLevel"

static  NSString *kSetupSelector = @"modSetUp:";
static  NSString *kInitSelector = @"modInit:";
static  NSString *kSplashSeletor = @"modSplash:";
static  NSString *kTearDownSelector = @"modTearDown:";
static  NSString *kWillResignActiveSelector = @"modWillResignActive:";
static  NSString *kDidEnterBackgroundSelector = @"modDidEnterBackground:";
static  NSString *kWillEnterForegroundSelector = @"modWillEnterForeground:";
static  NSString *kDidBecomeActiveSelector = @"modDidBecomeActive:";
static  NSString *kWillTerminateSelector = @"modWillTerminate:";
static  NSString *kUnmountEventSelector = @"modUnmount:";
static  NSString *kQuickActionSelector = @"modQuickAction:";
static  NSString *kOpenURLSelector = @"modOpenURL:";
static  NSString *kDidReceiveMemoryWarningSelector = @"modDidReceiveMemoryWaring:";
static  NSString *kFailToRegisterForRemoteNotificationsSelector = @"modDidFailToRegisterForRemoteNotifications:";
static  NSString *kDidRegisterForRemoteNotificationsSelector = @"modDidRegisterForRemoteNotifications:";
static  NSString *kDidReceiveRemoteNotificationsSelector = @"modDidReceiveRemoteNotification:";
static  NSString *kDidReceiveLocalNotificationsSelector = @"modDidReceiveLocalNotification:";
static  NSString *kWillPresentNotificationSelector = @"modWillPresentNotification:";
static  NSString *kDidReceiveNotificationResponseSelector = @"modDidReceiveNotificationResponse:";
static  NSString *kWillContinueUserActivitySelector = @"modWillContinueUserActivity:";
static  NSString *kContinueUserActivitySelector = @"modContinueUserActivity:";
static  NSString *kDidUpdateContinueUserActivitySelector = @"modDidUpdateContinueUserActivity:";
static  NSString *kFailToContinueUserActivitySelector = @"modDidFailToContinueUserActivity:";
static  NSString *kAppCustomSelector = @"modDidCustomEvent:";



@interface BHModuleManager()

@property(nonatomic, strong) NSMutableArray     *BHModuleDynamicClasses;

@property(nonatomic, strong) NSMutableArray<NSDictionary *>     *BHModuleInfos;
@property(nonatomic, strong) NSMutableArray     *BHModules;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<BHModuleProtocol>> *> *BHModulesByEvent;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *BHSelectorByEvent;

@end

@implementation BHModuleManager

#pragma mark - public

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[BHModuleManager alloc] init];
    });
    return sharedManager;
}

- (void)loadLocalModules
{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[BHContext shareInstance].moduleConfigName ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSDictionary *moduleList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *modulesArray = [moduleList objectForKey:kModuleArrayKey];
    
    [self.BHModuleInfos addObjectsFromArray:modulesArray];
    
}

- (void)registerDynamicModule:(Class)moduleClass
{
    [self addModuleFromObject:moduleClass];
 
}

- (void)registedAllModules
{

    [self.BHModuleInfos sortUsingComparator:^NSComparisonResult(NSDictionary *module1, NSDictionary *module2) {
      NSNumber *module1Level = (NSNumber *)[module1 objectForKey:kModuleInfoLevelKey];
      NSNumber *module2Level =  (NSNumber *)[module2 objectForKey:kModuleInfoLevelKey];
        
        return [module1Level intValue] > [module2Level intValue];
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    //module init
    [self.BHModuleInfos enumerateObjectsUsingBlock:^(NSDictionary *module, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *classStr = [module objectForKey:kModuleInfoNameKey];
        
        Class moduleClass = NSClassFromString(classStr);
        
        if (NSStringFromClass(moduleClass)) {
            id<BHModuleProtocol> moduleInstance = [[moduleClass alloc] init];
            [tmpArray addObject:moduleInstance];
        }
        
    }];
    
    [self.BHModules removeAllObjects];

    [self.BHModules addObjectsFromArray:tmpArray];
    
    [self registerAllSystemEvents];
}

- (void)registerCustomEvent:(NSInteger)eventType
   withModuleInstance:(id)moduleInstance
       andSelectorStr:(NSString *)selectorStr {
    if (eventType < 1000) {
        return;
    }
    [self registerEvent:eventType withModuleInstance:moduleInstance andSelectorStr:selectorStr];
}

- (void)triggerEvent:(NSInteger)eventType
{
    [self handleModuleEvent:eventType];
}


#pragma mark - life loop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.BHModuleDynamicClasses = [NSMutableArray array];
    }
    return self;
}


#pragma mark - private

- (BHModuleLevel)checkModuleLevel:(NSUInteger)level
{
    switch (level) {
        case 0:
            return BHModuleBasic;
            break;
        case 1:
            return BHModuleNormal;
            break;
        default:
            break;
    }
    //default normal
    return BHModuleNormal;
}


- (void)addModuleFromObject:(id)object
{
    Class class;
    NSString *moduleName = nil;
    
    if (object) {
        class = object;
        moduleName = NSStringFromClass(class);
    } else {
        return ;
    }
    
    if ([class conformsToProtocol:@protocol(BHModuleProtocol)]) {
        NSMutableDictionary *moduleInfo = [NSMutableDictionary dictionary];
        
        BOOL responseBasicLevel = [class instancesRespondToSelector:@selector(basicModuleLevel)];

        int levelInt = 1;
        
        if (responseBasicLevel) {
            levelInt = 0;
        }
        
        [moduleInfo setObject:@(levelInt) forKey:kModuleInfoLevelKey];
        if (moduleName) {
            [moduleInfo setObject:moduleName forKey:kModuleInfoNameKey];
        }

        [self.BHModuleInfos addObject:moduleInfo];
        
        id<BHModuleProtocol> moduleInstance = [[class alloc] init];
        [self.BHModules addObject:moduleInstance];
        [self.BHModules sortUsingComparator:^NSComparisonResult(id<BHModuleProtocol> moduleInstance1, id<BHModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(BHModuleNormal);
            NSNumber *module2Level = @(BHModuleNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(BHModuleBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(BHModuleBasic);
            }
            
            return [module1Level intValue] > [module2Level intValue];
        }];
        [self registerEventsByModuleInstance:moduleInstance];
    }
}

- (void)registerAllSystemEvents
{
    [self.BHModules enumerateObjectsUsingBlock:^(id<BHModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEventsByModuleInstance:moduleInstance];
    }];
}

- (void)registerEventsByModuleInstance:(id<BHModuleProtocol>)moduleInstance
{
    NSArray<NSNumber *> *events = self.BHSelectorByEvent.allKeys;
    [events enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEvent:obj.integerValue withModuleInstance:moduleInstance andSelectorStr:self.BHSelectorByEvent[obj]];
    }];
}

- (void)registerEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr {
    SEL selector = NSSelectorFromString(selectorStr);
    if (!selector || ![moduleInstance respondsToSelector:selector]) {
        return;
    }
    NSNumber *eventTypeNumber = @(eventType);
    if (![self.BHSelectorByEvent.allKeys containsObject:eventTypeNumber]) {
        [self.BHSelectorByEvent setObject:selectorStr forKey:eventTypeNumber];
    }
    if (![self.BHModulesByEvent.allKeys containsObject:eventTypeNumber]) {
        [self.BHModulesByEvent setObject:@[].mutableCopy forKey:eventTypeNumber];
    }
    NSMutableArray *eventModules = [self.BHModulesByEvent objectForKey:eventTypeNumber];
    if (![eventModules containsObject:moduleInstance]) {
        [eventModules addObject:moduleInstance];
    }
}

#pragma mark - property setter or getter
- (NSMutableArray<NSDictionary *> *)BHModuleInfos {
    if (!_BHModuleInfos) {
        _BHModuleInfos = @[].mutableCopy;
    }
    return _BHModuleInfos;
}

- (NSMutableArray *)BHModules
{
    if (!_BHModules) {
        _BHModules = [NSMutableArray array];
    }
    return _BHModules;
}

- (NSMutableDictionary<NSNumber *, NSMutableArray<id<BHModuleProtocol>> *> *)BHModulesByEvent
{
    if (!_BHModulesByEvent) {
        _BHModulesByEvent = @{}.mutableCopy;
    }
    return _BHModulesByEvent;
}

- (NSMutableDictionary<NSNumber *, NSString *> *)BHSelectorByEvent
{
    if (!_BHSelectorByEvent) {
        _BHSelectorByEvent = @{
                               @(BHMSetupEvent):kSetupSelector,
                               @(BHMInitEvent):kInitSelector,
                               @(BHMTearDownEvent):kTearDownSelector,
                               @(BHMSplashEvent):kSplashSeletor,
                               @(BHMWillResignActiveEvent):kWillResignActiveSelector,
                               @(BHMDidEnterBackgroundEvent):kDidEnterBackgroundSelector,
                               @(BHMWillEnterForegroundEvent):kWillEnterForegroundSelector,
                               @(BHMDidBecomeActiveEvent):kDidBecomeActiveSelector,
                               @(BHMWillTerminateEvent):kWillTerminateSelector,
                               @(BHMUnmountEvent):kUnmountEventSelector,
                               @(BHMOpenURLEvent):kOpenURLSelector,
                               @(BHMDidReceiveMemoryWarningEvent):kDidReceiveMemoryWarningSelector,
                               
                               @(BHMDidReceiveRemoteNotificationEvent):kDidReceiveRemoteNotificationsSelector,
                               @(BHMWillPresentNotificationEvent):kWillPresentNotificationSelector,
                               @(BHMDidReceiveNotificationResponseEvent):kDidReceiveNotificationResponseSelector,
                               
                               @(BHMDidFailToRegisterForRemoteNotificationsEvent):kFailToRegisterForRemoteNotificationsSelector,
                               @(BHMDidRegisterForRemoteNotificationsEvent):kDidRegisterForRemoteNotificationsSelector,
                               
                               @(BHMDidReceiveLocalNotificationEvent):kDidReceiveLocalNotificationsSelector,
                               
                               @(BHMWillContinueUserActivityEvent):kWillContinueUserActivitySelector,
                               
                               @(BHMContinueUserActivityEvent):kContinueUserActivitySelector,
                               
                               @(BHMDidFailToContinueUserActivityEvent):kFailToContinueUserActivitySelector,
                               
                               @(BHMDidUpdateUserActivityEvent):kDidUpdateContinueUserActivitySelector,
                               
                               @(BHMQuickActionEvent):kQuickActionSelector,
                               @(BHMDidCustomEvent):kAppCustomSelector,
                               }.mutableCopy;
    }
    return _BHSelectorByEvent;
}

#pragma mark - module protocol
- (void)handleModuleEvent:(NSInteger)eventType
{
    switch (eventType) {
        case BHMInitEvent:
            //special
            [self handleModulesInitEvent];
            break;
        case BHMTearDownEvent:
            //special
            [self handleModulesTearDownEvent];
            break;
        default: {
            NSString *selectorStr = [self.BHSelectorByEvent objectForKey:@(eventType)];
            [self handleModuleEvent:eventType withSeletorStr:selectorStr];
        }
            break;
    }
    
}

- (void)handleModulesInitEvent
{
    NSArray<id<BHModuleProtocol>> *moduleInstances = [self.BHModulesByEvent objectForKey:@(BHMInitEvent)];
    
    [moduleInstances enumerateObjectsUsingBlock:^(id<BHModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(&*self) wself = self;
        void ( ^ bk )();
        bk = ^(){
            __strong typeof(&*self) sself = wself;
            if (sself) {
                if ([moduleInstance respondsToSelector:@selector(modInit:)]) {
                    [moduleInstance modInit:[BHContext shareInstance]];
                }
            }
        };

        [[BHTimeProfiler sharedTimeProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- modInit:", [moduleInstance class]]];
        
        if ([moduleInstance respondsToSelector:@selector(async)]) {
            BOOL async = [moduleInstance async];
            
            if (async) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bk();
                });
                
            } else {
                bk();
            }
        } else {
            bk();
        }
    }];
}

- (void)handleModulesTearDownEvent
{
    NSArray<id<BHModuleProtocol>> *moduleInstances = [self.BHModulesByEvent objectForKey:@(BHMTearDownEvent)];
    //Reverse Order to unload
    for (int i = (int)moduleInstances.count - 1; i >= 0; i--) {
        id<BHModuleProtocol> moduleInstance = [moduleInstances objectAtIndex:i];
        if (moduleInstance && [moduleInstance respondsToSelector:@selector(modTearDown:)]) {
            [moduleInstance modTearDown:[BHContext shareInstance]];
        }
    }
}

- (void)handleModuleEvent:(NSInteger)eventType withSeletorStr:(NSString *)selectorStr
{
    if (eventType >= 1000) {
        [BHContext shareInstance].customEvent = eventType;
    }
    SEL seletor = NSSelectorFromString(selectorStr);
    NSArray<id<BHModuleProtocol>> *moduleInstances = [self.BHModulesByEvent objectForKey:@(eventType)];
    [moduleInstances enumerateObjectsUsingBlock:^(id<BHModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([moduleInstance respondsToSelector:seletor]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [moduleInstance performSelector:seletor withObject:[BHContext shareInstance]];
#pragma clang diagnostic pop
            
            [[BHTimeProfiler sharedTimeProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- %@", [moduleInstance class], NSStringFromSelector(seletor)]];
            
        }
    }];
}

@end

