//
//  BHRouter.m
//  BeeHive
//
//  Created by 张旻可 on 2017/7/17.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import "BHRouter.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "BHModuleProtocol.h"
#import "BHServiceProtocol.h"
#import "BHCommon.h"
#import "BHModuleManager.h"
#import "BHServiceManager.h"

static NSString *const BHRClassRegex = @"(?<=T@\")(.*)(?=\",)";

typedef NS_ENUM(NSUInteger, BHRViewControlerEnterMode) {
    BHRViewControlerEnterModePush,
    BHRViewControlerEnterModeModal
};

typedef NS_ENUM(NSUInteger, BHRUsage) {
    BHRUsageUnknown,
    BHRUsageCallService,
    BHRUsageJumpViewControler,
    BHRUsageRegister
};

static NSMutableDictionary<NSString *, BHRouter *> *routerByScheme = nil;


@interface BHRPathComponent : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) Class mClass;
@property (nonatomic, copy) NSDictionary<NSString *, id> *params;
@property (nonatomic, copy) BHRPathComponentCustomHandler handler;

@end

@implementation BHRPathComponent



@end

static NSString *BHRURLGlobalScheme = nil;

@interface BHRouter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, BHRPathComponent *> *pathComponentByKey;
@property (nonatomic, copy) NSString *scheme;

@end

@implementation BHRouter

#pragma mark - property init
- (NSMutableDictionary<NSString *, BHRPathComponent *> *)pathComponentByKey {
    if (!_pathComponentByKey) {
        _pathComponentByKey = @{}.mutableCopy;
    }
    return _pathComponentByKey;
}

#pragma mark - router init

+ (instancetype)globalRouter
{
    if (!BHRURLGlobalScheme) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:[BHContext shareInstance].moduleConfigName ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            BHRURLGlobalScheme = [plist objectForKey:BHRURLSchemeGlobalKey];
        }
        if (!BHRURLGlobalScheme.length) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            BHRURLGlobalScheme = [infoDictionary objectForKey:@"CFBundleIdentifier"];
        }
        if (!BHRURLGlobalScheme.length) {
            BHRURLGlobalScheme = @"com.alibaba.beehive";
        }
    }
    return [self routerForScheme:BHRURLGlobalScheme];
}
+ (instancetype)routerForScheme:(NSString *)scheme
{
    if (!scheme.length) {
        return nil;
    }
    
    BHRouter *router = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routerByScheme = @{}.mutableCopy;
    });
    
    if (!routerByScheme[scheme]) {
        router = [[self alloc] init];
        router.scheme = scheme;
        [routerByScheme setObject:router forKey:scheme];
    } else {
        router = [routerByScheme objectForKey:scheme];
    }
    
    return router;
}

+ (void)unRegisterRouterForScheme:(NSString *)scheme
{
    if (!scheme.length) {
        return;
    }
    
    [routerByScheme removeObjectForKey:scheme];
}
+ (void)unRegisterAllRouters
{
    [routerByScheme removeAllObjects];
}

- (void)addPathComponent:(NSString *)pathComponentKey
       forClass:(Class)mClass
{
    [self addPathComponent:pathComponentKey forClass:mClass handler:nil];
}
//handler is a custom module or service init function
- (void)addPathComponent:(NSString *)pathComponentKey
       forClass:(Class)mClass
        handler:(BHRPathComponentCustomHandler)handler
{
    BHRPathComponent *pathComponent = [[BHRPathComponent alloc] init];
    pathComponent.key = pathComponentKey;
    pathComponent.mClass = mClass;
    pathComponent.handler = handler;
    [self.pathComponentByKey setObject:pathComponent forKey:pathComponentKey];
}
- (void)removePathComponent:(NSString *)pathComponentKey
{
    [self.pathComponentByKey removeObjectForKey:pathComponentKey];
}

+ (BOOL)canOpenURL:(NSURL *)URL
{
    if (!URL) {
        return NO;
    }
    NSString *scheme = URL.scheme;
    if (!scheme.length) {
        return NO;
    }
    
    NSString *host = URL.host;
    BHRUsage usage = [self usage:host];
    if (usage == BHRUsageUnknown) {
        return NO;
    }
    
    BHRouter *router = [self routerForScheme:scheme];
    
    NSArray<NSString *> *pathComponents = URL.pathComponents;
    
    __block BOOL flag = YES;
    
    [pathComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> * subPaths = [obj componentsSeparatedByString:BHRURLSubPathSplitPattern];
        if (!subPaths.count) {
            flag = NO;
            *stop = NO;
            return;
        }
        NSString *pathComponentKey = subPaths.firstObject;
        if (router.pathComponentByKey[pathComponentKey]) {
            return;
        }
        Class mClass = NSClassFromString(pathComponentKey);
        if (!mClass) {
            flag = NO;
            *stop = NO;
            return;
        }
        switch (usage) {
            case BHRUsageCallService: {
                if (subPaths.count < 3) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
                NSString *protocolStr = subPaths[1];
                NSString *selectorStr = subPaths[2];
                Protocol *protocol = NSProtocolFromString(protocolStr);
                SEL selector = NSSelectorFromString(selectorStr);
                if (!protocol ||
                    !selector ||
                    ![mClass conformsToProtocol:@protocol(BHServiceProtocol)] ||
                    ![mClass conformsToProtocol:protocol] ||
                    ![mClass respondsToSelector:selector]) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
            } break;
            case BHRUsageJumpViewControler: {
                if (![mClass isKindOfClass:[UIViewController class]]) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
            } break;
            case BHRUsageRegister: {
                if (![mClass conformsToProtocol:@protocol(BHServiceProtocol)]) {
                    return;
                }
                if (subPaths.count < 2) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
                NSString *protocolStr = subPaths[1];
                Protocol *protocol = NSProtocolFromString(protocolStr);
                if (!protocol || ![mClass conformsToProtocol:protocol]) {
                    flag = NO;
                    *stop = NO;
                }
            } break;
                
            default:
                break;
        }
    }];
    
    return flag;
}
+ (BOOL)openURL:(NSURL *)URL
{
    return [self openURL:URL withParams:nil andThen:nil];
}
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
{
    return [self openURL:URL withParams:params andThen:nil];
}
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
        andThen:(void(^)(NSString *pathComponentKey, id obj, id returnValue))then
{
    if (![self canOpenURL:URL]) {
        return NO;
    }
    
    NSString *scheme = URL.scheme;
    BHRouter *router = [self routerForScheme:scheme];
    
    NSString *host = URL.host;
    BHRUsage usage = [self usage:host];
    
    BHRViewControlerEnterMode defaultMode = BHRViewControlerEnterModePush;
    if (URL.fragment.length) {
        defaultMode = [self viewControllerEnterMode:URL.fragment];
    }
    
    
    NSDictionary<NSString *, NSString *> *queryDic = [self queryDicFromURL:URL];
    NSString *paramsJson = [queryDic objectForKey:BHRURLQueryParamsKey];
    NSDictionary<NSString *, NSDictionary<NSString *, id> *> *allURLParams = [self paramsFromJson:paramsJson];
    
    NSArray<NSString *> *pathComponents = URL.pathComponents;
    
    [pathComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:@"/"]) {
            
            NSArray<NSString *> * subPaths = [obj componentsSeparatedByString:BHRURLSubPathSplitPattern];
            NSString *pathComponentKey = subPaths.firstObject;
            
            Class mClass;
            BHRPathComponentCustomHandler handler;
            BHRPathComponent *pathComponent = [router.pathComponentByKey objectForKey:pathComponentKey];
            if (pathComponent) {
                mClass = pathComponent.mClass;
                handler = pathComponent.handler;
            } else {
                mClass = NSClassFromString(pathComponentKey);
            }
            
            NSDictionary<NSString *, id> *URLParams = [allURLParams objectForKey:pathComponentKey];
            NSDictionary<NSString *, id> *funcParams = [params objectForKey:pathComponentKey];
            NSDictionary<NSString *, id> *finalParams = [self solveURLParams:URLParams withFuncParams:funcParams forClass:usage == BHRUsageCallService ? nil : mClass];
            
            if (handler) {
                handler(finalParams);
                return;
            }
            
            NSString *protocolStr;
            Protocol *protocol;
            if (subPaths.count >= 2) {
                protocolStr = subPaths[1];
                protocol = NSProtocolFromString(protocolStr);
            }
            
            id obj;
            id returnValue;
            
            switch (usage) {
                case BHRUsageCallService: {
                    NSString *selectorStr = subPaths[2];
                    SEL selector = NSSelectorFromString(selectorStr);
                    obj = [[BHServiceManager sharedManager] createService:protocol];
                    returnValue = [self safePerformAction:selector forTarget:obj withParams:finalParams];
                } break;
                case BHRUsageJumpViewControler: {
                    BHRViewControlerEnterMode enterMode = defaultMode;
                    if (subPaths.count >= 3) {
                        enterMode = [self viewControllerEnterMode:subPaths[2]];
                    }
                    
                    if ([mClass conformsToProtocol:@protocol(BHServiceProtocol)] && protocol) {
                        obj = [[BHServiceManager sharedManager] createService:protocol];
                    } else {
                        obj = [[mClass alloc] init];
                    }
                    [obj setObject:obj forKey:finalParams];
                    BOOL isLast = pathComponents.count - 1 ? YES : NO;
                    [self solveJumpWithViewController:(UIViewController *)obj andJumpMode:enterMode shouldAnimate:isLast];
                } break;
                case BHRUsageRegister: {
                    if ([mClass conformsToProtocol:@protocol(BHModuleProtocol)]) {
                        [[BHModuleManager sharedManager] registerDynamicModule:mClass];
                    } else if ([mClass conformsToProtocol:@protocol(BHServiceProtocol)] && protocol) {
                        [[BHServiceManager sharedManager] registerService:protocol implClass:mClass];
                    }
                } break;
                    
                default:
                    break;
            }
            !then?:then(pathComponentKey, obj, returnValue);
        }
    }];
    
    return YES;
}

#pragma mark - private
+ (BHRUsage)usage:(NSString *)usagePattern
{
    usagePattern = usagePattern.lowercaseString;
    if ([usagePattern isEqualToString:BHRURLHostCallService]) {
        return BHRUsageCallService;
    } else if ([usagePattern isEqualToString:BHRURLHostJumpViewController]) {
        return BHRUsageJumpViewControler;
    } else if ([usagePattern isEqualToString:BHRURLHostRegister]) {
        return BHRUsageRegister;
    }
    return BHRUsageUnknown;
}

+ (BHRViewControlerEnterMode)viewControllerEnterMode:(NSString *)enterModePattern
{
    enterModePattern = enterModePattern.lowercaseString;
    if ([enterModePattern isEqualToString:BHRURLFragmentViewControlerEnterModePush]) {
        return BHRViewControlerEnterModePush;
    } else if ([enterModePattern isEqualToString:BHRURLFragmentViewControlerEnterModeModal]) {
        return BHRViewControlerEnterModeModal;
    }
    return BHRViewControlerEnterModePush;
}

+ (UIViewController *)currentViewController
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (viewController) {
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tbvc = (UITabBarController*)viewController;
            viewController = tbvc.selectedViewController;
        } else if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)viewController;
            viewController = nvc.topViewController;
        } else if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:[UISplitViewController class]] &&
                   ((UISplitViewController *)viewController).viewControllers.count > 0) {
            UISplitViewController *svc = (UISplitViewController *)viewController;
            viewController = svc.viewControllers.lastObject;
        } else  {
            return viewController;
        }
    }
    return viewController;
}

+ (NSDictionary<NSString *, id> *)queryDicFromURL:(NSURL *)URL
{
    if (!URL) {
        return nil;
    }
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        NSString *query = URL.query;
        NSArray<NSString *> *queryStrs = [query componentsSeparatedByString:@"&"];
        [queryStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *keyValue = [obj componentsSeparatedByString:@"="];
            if (keyValue.count >= 2) {
                NSString *key = keyValue[0];
                NSString *value = keyValue[1];
                [dic setObject:value forKey:key];
            }
        }];
        return dic;
    } else {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = URLComponents.queryItems;
        NSMutableDictionary *dic = @{}.mutableCopy;
        for (NSURLQueryItem *item in queryItems) {
            if (item.name && item.value) {
                [dic setObject:item.value forKey:item.name];
            }
        }
        return dic;
    }
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)paramsFromJson:(NSString *)json
{
    if (!json.length) {
        return nil;
    }
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        BHLog(@"BeeHive-BHRouter [Error] Wrong URL Query Format: \n%@", error.description);
    }
    return dic;
}

+ (NSDictionary<NSString *, id> *)solveURLParams:(NSDictionary<NSString *, id> *)URLParams
                                  withFuncParams:(NSDictionary<NSString *, id> *)funcParams
                                        forClass:(Class)mClass
{
    if (!URLParams) {
        URLParams = @{};
    }
    NSMutableDictionary<NSString *, id> *params = URLParams.mutableCopy;
    NSArray<NSString *> *funcParamKeys = funcParams.allKeys;
    [funcParamKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [params setObject:funcParams[obj] forKey:obj];
    }];
    if (mClass) {
        NSArray<NSString *> *paramKeys = params.allKeys;
        [paramKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            objc_property_t prop = class_getProperty(mClass, obj.UTF8String);
            if (!prop) {
                [params removeObjectForKey:obj];
            } else {
                NSString *propAttr = [[NSString alloc] initWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
                NSRange range = [propAttr rangeOfString:BHRClassRegex options:NSRegularExpressionSearch];
                if (range.length != 0) {
                    NSString *propClassName = [propAttr substringWithRange:range];
                    Class propClass = objc_getClass([propClassName UTF8String]);
                    if ([propClass isSubclassOfClass:[NSString class]] && [params[obj] isKindOfClass:[NSNumber class]]) {
                        [params setObject:[NSString stringWithFormat:@"%@", params[obj]] forKey:obj];
                    } else if ([propClass isSubclassOfClass:[NSNumber class]] && [params[obj] isKindOfClass:[NSString class]]) {
                        [params setObject:@(((NSString *)params[obj]).doubleValue) forKey:obj];
                    }
                    
                }
            }
        }];
    }
    return params;
}

+ (void)setObject:(id)object
    withPropertys:(NSDictionary<NSString *, id> *)propertys
{
    if (!object) {
        return;
    }
    [propertys enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [object setValue:obj forKey:key];
    }];
}

+ (void)solveJumpWithViewController:(UIViewController *)viewController
                        andJumpMode:(BHRViewControlerEnterMode)enterMode
                      shouldAnimate:(BOOL)animate
{
    UIViewController *currentViewController = [self currentViewController];
    switch (enterMode) {
        case BHRViewControlerEnterModePush:
            [currentViewController.navigationController pushViewController:viewController animated:animate];
            break;
        case BHRViewControlerEnterModeModal:
            [currentViewController presentViewController:viewController animated:animate completion:^{
                
            }];
            break;
            
        default:
            break;
    }
}

+ (id)safePerformAction:(SEL)action
              forTarget:(NSObject *)target
             withParams:(NSDictionary *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    NSArray<NSString *> *keys = params.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        if (obj1.integerValue < obj2.integerValue) {
            return NSOrderedAscending;
        } else if (obj1.integerValue == obj2.integerValue) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[obj];
        [invocation setArgument:&value atIndex:idx+2];
    }];
    [invocation setSelector:action];
    [invocation setTarget:target];
    [invocation invoke];
    if (strcmp(retType, @encode(void)) == 0) {
        return nil;
    } else if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    } else if (strcmp(retType, @encode(BOOL)) == 0) {
        BOOL result = NO;
        [invocation getReturnValue:&result];
        return @(result);
    } else if (strcmp(retType, @encode(CGFloat)) == 0) {
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    } else if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    } else {
        id result = nil;
        [invocation getReturnValue:&result];
        return result;
    }
}

@end
