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
static const NSString *kService = @"service";
static const NSString *kImpl = @"impl";

@interface BHServiceManager()

@property (nonatomic, strong) NSMutableArray *allServices;
@property (nonatomic, strong) NSRecursiveLock *lock;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)registerLocalServices
{
    NSString *serviceConfigName = self.wholeContext.serviceConfigName;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:serviceConfigName  ofType:@"plist"];
    if (!plistPath) {
        return;
    }
    
    NSArray *serviceList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    [self.lock lock];
    [self.allServices addObjectsFromArray:serviceList];
    [self.lock unlock];
}

- (void)registerAnnotationServices
{
    NSArray<NSString *>*services = [BHAnnotation AnnotationServices];
    
    for (NSString *map in services) {
        NSData *jsonData =  [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                
                NSString *protocol = [json allKeys][0];
                NSString *clsName  = [json allValues][0];
                
                if (protocol && clsName) {
                    [self registerService:NSProtocolFromString(protocol) implClass:NSClassFromString(clsName)];
                }
                
            }
        }
    }

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
        id protocol = [[BHContext shareInstance].servicesByName objectForKey:serviceStr];
        
        if (protocol) {
            return protocol;
        } else {
            [[BHContext shareInstance].servicesByName setObject:implInstance forKey:serviceStr];
        }
        
    } else {
        [[BHContext shareInstance].servicesByName setObject:implInstance forKey:serviceStr];
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
    NSArray *array = [self.allServices mutableCopy];
    [self.lock unlock];
    return array;
}

@end
