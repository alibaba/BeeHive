//
//  BHRouter.h
//  BeeHive
//
//  Created by 张旻可 on 2017/7/17.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const BHRModuleScheme = @"BHRouterModuleScheme";
static NSString *const BHRServiceScheme = @"BHRouterServiceScheme";

static NSString *const BHRViewControlerEnterModePatternPush = @"push";
static NSString *const BHRViewControlerEnterModePatternModal = @"modal";

static NSString *const BHRViewControlerPathSubPattern = @".";

static NSString *const BHRURLQueryParamsKey = @"params";

typedef void(^BHRPathComponentCustomHandler)(NSDictionary<NSString *, id> *params);

@interface BHRouter : NSObject


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)moduleRouter;
+ (instancetype)serviceRouter;
+ (instancetype)routerForScheme:(NSString *)scheme;

+ (void)unRegisterRouterForScheme:(NSString *)scheme;
+ (void)unRegisterAllRouters;

//handler is a custom module or service init function
- (void)addPathComponent:(NSString *)pathComponentKey
       forClass:(Class)mClass;
- (void)addPathComponent:(NSString *)pathComponentKey
       forClass:(Class)mClass
        handler:(BHRPathComponentCustomHandler)handler;
- (void)removePathComponent:(NSString *)pathComponentKey;

//url - >  BHRouterServiceScheme://bundleid/pathComponentKey.protocolName.push(modal)/...?params={}(value url encode)#push
//params -> {pathComponentKey:{paramName:paramValue,...},...}
+ (BOOL)canOpenURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
        andThen:(void(^)(NSURL *URL))then;

@end
