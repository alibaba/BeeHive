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
static  NSString *kWillContinueUserActivitySelector = @"modWillContinueUserActivity:";
static  NSString *kContinueUserActivitySelector = @"modContinueUserActivity:";
static  NSString *kDidUpdateContinueUserActivitySelector = @"modDidUpdateContinueUserActivity:";
static  NSString *kFailToContinueUserActivitySelector = @"modDidFailToContinueUserActivity:";




@interface BHModuleManager()

@property(nonatomic, strong) NSMutableArray     *BHModuleDynamicClasses;

@property(nonatomic, strong)  NSMutableArray      *BHModules;


@end

@implementation BHModuleManager

#pragma mark - public

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)loadLocalModules
{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.modulesConfigFilename ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSDictionary *moduleList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *modulesArray = [moduleList objectForKey:kModuleArrayKey];
    
    [self.BHModules addObjectsFromArray:modulesArray];
    
}

- (void)registerDynamicModule:(Class)moduleClass
{
    [self addModuleFromObject:moduleClass];
 
}

- (void)registedAllModules
{

    [self.BHModules sortUsingComparator:^NSComparisonResult(NSDictionary *module1, NSDictionary *module2) {
      NSNumber *module1Level = (NSNumber *)[module1 objectForKey:kModuleInfoLevelKey];
      NSNumber *module2Level =  (NSNumber *)[module2 objectForKey:kModuleInfoLevelKey];
        
        return [module1Level intValue] > [module2Level intValue];
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    //module init
    [self.BHModules enumerateObjectsUsingBlock:^(NSDictionary *module, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *classStr = [module objectForKey:kModuleInfoNameKey];
        
        Class moduleClass = NSClassFromString(classStr);
        
        if (NSStringFromClass(moduleClass)) {
            id<BHModuleProtocol> moduleInstance = [[moduleClass alloc] init];
            [tmpArray addObject:moduleInstance];
        }
        
    }];
    
    [self.BHModules removeAllObjects];

    [self.BHModules addObjectsFromArray:tmpArray];
    
}

- (void)registedAnnotationModules
{
    
    NSArray<NSString *>*mods = [BHAnnotation AnnotationModules];
    for (NSString *modName in mods) {
        Class cls;
        if (modName) {
            cls = NSClassFromString(modName);
            
            if (cls) {
                [self registerDynamicModule:cls];
            }
        }
    }
}


- (void)triggerEvent:(BHModuleEventType)eventType
{
    switch (eventType) {
        case BHMSetupEvent:
            [self handleModuleEvent:kSetupSelector];
            break;
        case BHMInitEvent:
            //special
            [self handleModulesInitEvent];
            break;
        case BHMTearDownEvent:
            //special
            [self handleModulesTearDownEvent];
            break;
        case BHMSplashEvent:
            [self handleModuleEvent:kSplashSeletor];
            break;
        case BHMWillResignActiveEvent:
            [self handleModuleEvent:kWillResignActiveSelector];
            break;
        case BHMDidEnterBackgroundEvent:
            [self handleModuleEvent:kDidEnterBackgroundSelector];
            break;
        case BHMWillEnterForegroundEvent:
            [self handleModuleEvent:kWillEnterForegroundSelector];
            break;
        case BHMDidBecomeActiveEvent:
            [self handleModuleEvent:kDidBecomeActiveSelector];
            break;
        case BHMWillTerminateEvent:
            [self handleModuleEvent:kWillTerminateSelector];
            break;
        case BHMUnmountEvent:
            [self handleModuleEvent:kUnmountEventSelector];
            break;
        case BHMOpenURLEvent:
            [self handleModuleEvent:kOpenURLSelector];
            break;
        case BHMDidReceiveMemoryWarningEvent:
            [self handleModuleEvent:kDidReceiveMemoryWarningSelector];
            break;
            
        case BHMDidReceiveRemoteNotificationEvent:
            [self handleModuleEvent:kDidReceiveRemoteNotificationsSelector];
            break;

        case BHMDidFailToRegisterForRemoteNotificationsEvent:
            [self handleModuleEvent:kFailToRegisterForRemoteNotificationsSelector];
            break;
        case BHMDidRegisterForRemoteNotificationsEvent:
            [self handleModuleEvent:kDidRegisterForRemoteNotificationsSelector];
            break;
            
        case BHMDidReceiveLocalNotificationEvent:
            [self handleModuleEvent:kDidReceiveLocalNotificationsSelector];
            break;
            
        case BHMWillContinueUserActivityEvent:
            [self handleModuleEvent:kWillContinueUserActivitySelector];
            break;
            
        case BHMContinueUserActivityEvent:
            [self handleModuleEvent:kContinueUserActivitySelector];
            break;
            
        case BHMDidFailToContinueUserActivityEvent:
            [self handleModuleEvent:kFailToContinueUserActivitySelector];
            break;
            
        case BHMDidUpdateUserActivityEvent:
            [self handleModuleEvent:kDidUpdateContinueUserActivitySelector];
            break;
            
        case BHMQuickActionEvent:
            [self handleModuleEvent:kQuickActionSelector];
            break;
            
        default:
            break;
    }
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

        [self.BHModules addObject:moduleInfo];
    }
}

#pragma mark - property setter or getter

- (void)setModulesConfigFilename:(NSString *)modulesConfigFilename
{
    _modulesConfigFilename = modulesConfigFilename;
}

- (void)setWholeContext:(BHContext *)wholeContext
{
    _wholeContext = wholeContext;
    self.modulesConfigFilename = _wholeContext.moduleConfigName;
}

- (NSMutableArray *)BHModules
{
    if (!_BHModules) {
        _BHModules = [NSMutableArray array];
    }
    return _BHModules;
}

#pragma mark - module protocol

- (void)handleModulesInitEvent
{
    
    [self.BHModules enumerateObjectsUsingBlock:^(id<BHModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(&*self) wself = self;
        void ( ^ bk )();
        bk = ^(){
            __strong typeof(&*self) sself = wself;
            if (sself) {
                if ([moduleInstance respondsToSelector:@selector(modInit:)]) {
                    [moduleInstance modInit:sself.wholeContext];
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
    //Reverse Order to unload
    for (int i = (int)self.BHModules.count - 1; i >= 0; i--) {
        id<BHModuleProtocol> moduleInstance = [self.BHModules objectAtIndex:i];
        if (moduleInstance && [moduleInstance respondsToSelector:@selector(modTearDown:)]) {
            [moduleInstance modTearDown:self.wholeContext];
        }
    }
}

- (void)handleModuleEvent:(NSString *)selectorStr
{
    SEL seletor = NSSelectorFromString(selectorStr);
    [self.BHModules enumerateObjectsUsingBlock:^(id<BHModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([moduleInstance respondsToSelector:seletor]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [moduleInstance performSelector:seletor withObject:self.wholeContext];
#pragma clang diagnostic pop

        [[BHTimeProfiler sharedTimeProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- %@", [moduleInstance class], NSStringFromSelector(seletor)]];

        }
    }];
}

@end

