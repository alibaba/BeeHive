//
//  BHRouter.h
//  BeeHive
//
//  Created by 张旻可 on 2017/7/17.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const BHRURLSchemeGlobalKey = @"URLGlobalScheme";
static NSString *const BHRURLHostCallService = @"call.service.beehive";
static NSString *const BHRURLHostRegister = @"register.beehive";
static NSString *const BHRURLHostJumpViewController = @"jump.vc.beehive";
static NSString *const BHRURLSubPathSplitPattern = @".";
static NSString *const BHRURLQueryParamsKey = @"params";
static NSString *const BHRURLFragmentViewControlerEnterModePush = @"push";
static NSString *const BHRURLFragmentViewControlerEnterModeModal = @"modal";



typedef void(^BHRPathComponentCustomHandler)(NSDictionary<NSString *, id> *params);

@interface BHRouter : NSObject


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)globalRouter;
+ (instancetype)routerForScheme:(NSString *)scheme;

+ (void)unRegisterRouterForScheme:(NSString *)scheme;
+ (void)unRegisterAllRouters;

//handler is a custom module or service solve function
- (void)addPathComponent:(NSString *)pathComponentKey
       forClass:(Class)mClass;
- (void)addPathComponent:(NSString *)pathComponentKey
       forClass:(Class)mClass
        handler:(BHRPathComponentCustomHandler)handler;
- (void)removePathComponent:(NSString *)pathComponentKey;

//url - >  com.alibaba.beehive://call.service.beehive/pathComponentKey.protocolName.selector/...?params={}(value url encode)
//url - >  com.alibaba.beehive://register.beehive/pathComponentKey.protocolName/...?params={}(value url encode)
//url - >  com.alibaba.beehive://jump.vc.beehive/pathComponentKey.protocolName.push(modal)/...?params={}(value url encode)#push
//params -> {pathComponentKey:{paramName:paramValue,...},...}
//when call service， paramName = @1,@2,...(order of paramValue)
+ (BOOL)canOpenURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
        andThen:(void(^)(NSString *pathComponentKey, id obj, id returnValue))then;

@end
