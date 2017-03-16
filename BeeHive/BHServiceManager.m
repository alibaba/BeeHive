/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
#import "BHServiceManager.h"
#import "BHContext.h"
#import "BHAnnotation.h"

#define kServiceArrayKey     @"serviceClasses"
static const NSString *kService = @"service";
static const NSString *kImpl = @"impl";

@interface BHServiceManager()

@property (nonatomic, strong) NSMutableArray *allServices;
@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation BHServiceManager

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)registerLocalServices
{
    NSString *serviceConfigName = [BHContext shareInstance].serviceConfigName;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:serviceConfigName ofType:@"plist"];
    if (!plistPath) {
        return;
    }
    NSSet *set =
    NSDictionary *serviceList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *serviceArray = [serviceList objectForKey:kServiceArrayKey];
    
    [self.lock lock];
    [self.allServices addObjectsFromArray:serviceArray];
    [self.lock unlock];
}

- (void)registerService:(Protocol *)service implClass:(Class)implClass
{
    NSParameterAssert(service != nil);
    NSParameterAssert(implClass != nil);
    
    if (![implClass conformsToProtocol:service] && self.enableException) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(service)] userInfo:nil];
    }
    
    if ([self checkValidService:service] && self.enableException) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol has been registed", NSStringFromProtocol(service)] userInfo:nil];
    }
    
    NSMutableDictionary *serviceInfo = [NSMutableDictionary dictionary];
    [serviceInfo setObject:NSStringFromProtocol(service) forKey:kService];
    [serviceInfo setObject:NSStringFromClass(implClass) forKey:kImpl];
    
    [self.lock lock];
    [self.allServices addObject:serviceInfo];
    [self.lock unlock];
}

- (id)createService:(Protocol *)service
{
    id implInstance = nil;
    
    if (![self checkValidService:service] && self.enableException) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol does not been registed", NSStringFromProtocol(service)] userInfo:nil];
    }
    
    Class implClass = [self serviceImplClass:service];
    
    if ([[implClass class] respondsToSelector:@selector(shareInstance)])
        implInstance = [[implClass class] shareInstance];
    else
        implInstance = [[implClass alloc] init];
    
    if (![implInstance respondsToSelector:@selector(singleton)]) {
        return implInstance;
    }
    
    NSString *serviceStr = NSStringFromProtocol(service);
    
    if ([implInstance singleton]) {
        id protocol = [[BHContext shareInstance] getServiceInstanceFromServiceName:serviceStr];
        
        if (protocol) {
            return protocol;
        } else {
            [[BHContext shareInstance] addServiceWithImplInstance:implInstance serviceName:serviceStr];
        }
        
    } else {
        [[BHContext shareInstance] addServiceWithImplInstance:implInstance serviceName:serviceStr];
    }
    
    return implInstance;
}

#pragma mark - private
- (Class)serviceImplClass:(Protocol *)service
{
    for (NSDictionary *serviceInfo in [self servicesArray]) {
        NSString *protocolStr = [serviceInfo objectForKey:kService];
        if ([protocolStr isEqualToString:NSStringFromProtocol(service)]) {
            NSString *classStr = [serviceInfo objectForKey:kImpl];
            return NSClassFromString(classStr);
        }
    }
    
    return nil;
}

- (BOOL)checkValidService:(Protocol *)service
{
    for (NSDictionary *serviceInfo in [self servicesArray]) {
        NSString *protocolStr = [serviceInfo objectForKey:kService];
        if ([protocolStr isEqualToString:NSStringFromProtocol(service)]) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)allServices
{
    if (!_allServices) {
        _allServices = [NSMutableArray array];
    }
    return _allServices;
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (NSArray *)servicesArray
{
    [self.lock lock];
    NSArray *array = [self.allServices copy];
    [self.lock unlock];
    return array;
}

@end
