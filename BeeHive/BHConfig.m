/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BHConfig.h"
#import "BHCommon.h"

@interface BHConfig()

@property(nonatomic, strong) NSMutableDictionary *config;

@end

@implementation BHConfig

static BHConfig *_BHConfigInstance;


+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    
    dispatch_once(&p, ^{
        _BHConfigInstance = [[[self class] alloc] init];
    });
    return _BHConfigInstance;
}


+ (NSString *)stringValue:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return nil;
    }
    
    return (NSString *)[[BHConfig shareInstance].config objectForKey:key];
}

+ (NSDictionary *)dictionaryValue:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return nil;
    }
    
    if (![[[BHConfig shareInstance].config objectForKey:key] isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return (NSDictionary *)[[BHConfig shareInstance].config objectForKey:key];
}

+ (NSArray *)arrayValue:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return nil;
    }
    
    if (![[[BHConfig shareInstance].config objectForKey:key] isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    return (NSArray *)[[BHConfig shareInstance].config objectForKey:key];
}

+ (NSInteger)integerValue:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return 0;
    }
    
    return [[[BHConfig shareInstance].config objectForKey:key] integerValue];
}

+ (float)floatValue:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return 0.0;
    }
    
    return [(NSNumber *)[[BHConfig shareInstance].config objectForKey:key] floatValue];
}

+ (BOOL)boolValue:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return NO;
    }
    
    return [(NSNumber *)[[BHConfig shareInstance].config objectForKey:key] boolValue];
}


+ (id)get:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        @throw [NSException exceptionWithName:@"ConfigNotInitialize" reason:@"config not initialize" userInfo:nil];
        
        return nil;
    }
    
    id v = [[BHConfig shareInstance].config objectForKey:key];
    if (!v) {
        BHLog(@"InvaildKeyValue %@ is nil", key);
    }
    
    return v;
}

+ (BOOL)has:(NSString *)key
{
    if (![BHConfig shareInstance].config) {
        return NO;
    }
    
    if (![[BHConfig shareInstance].config objectForKey:key]) {
        return NO;
    }
    
    return YES;
}

+ (void)set:(NSString *)key value:(id)value
{
    if (![BHConfig shareInstance].config) {
        [BHConfig shareInstance].config = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    [[BHConfig shareInstance].config setObject:value forKey:key];
}


+ (void)set:(NSString *)key boolValue:(BOOL)value
{
    [self set:key value:[NSNumber numberWithBool:value]];
}

+ (void)set:(NSString *)key integerValue:(NSInteger)value
{
    [self set:key value:[NSNumber numberWithInteger:value]];
}


+ (void) add:(NSDictionary *)parameters
{
    if (![BHConfig shareInstance].config) {
        [BHConfig shareInstance].config = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    [[BHConfig shareInstance].config addEntriesFromDictionary:parameters];
}

+ (NSDictionary *) getAll
{
    return [BHConfig shareInstance].config;
}

+ (void)clear
{
    if ([BHConfig shareInstance].config) {
        [[BHConfig shareInstance].config removeAllObjects];
    }
}

@end
