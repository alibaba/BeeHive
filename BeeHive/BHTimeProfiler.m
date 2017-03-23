/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BHTimeProfiler.h"
#import "BHCommon.h"
#include <QuartzCore/QuartzCore.h>


#if __has_feature(objc_generics)
#   define TM__GENERICS(class, ...)         class<__VA_ARGS__>
#else
#   define TM__GENERICS(class, ...)         class
#endif

#define TMMutableArrayWith(valueType)                   TM__GENERICS(NSMutableArray, valueType)
#define TMMutableDictionaryWith(keyType, valueType)     TM__GENERICS(NSMutableDictionary, keyType, valueType)


@interface BHTimeProfiler()
@property (nonatomic, copy)   NSString *mainIdentifier;
@property (nonatomic, strong) TMMutableArrayWith(NSString *) *identifiers;
@property (nonatomic, strong) TMMutableDictionaryWith(NSString *, NSNumber *) *timeDataDic;
@property (nonatomic)         CFTimeInterval lastTime;
@property (nonatomic)         CFTimeInterval recordStartTime;
@end

@implementation BHTimeProfiler

+ (BHTimeProfiler *)sharedTimeProfiler
{
    static dispatch_once_t onceToken;
    static BHTimeProfiler *profiler = nil;
    dispatch_once(&onceToken, ^{
        profiler = [[BHTimeProfiler alloc] initTimeProfilerWithMainKey:@""];
    });
    return profiler;
}

- (instancetype)initTimeProfilerWithMainKey:(NSString *)mainKey
{
    self = [super init];
    if (self) {
        _mainIdentifier = [mainKey copy];
        _lastTime = CACurrentMediaTime();
        _recordStartTime = CACurrentMediaTime();
    }
    return self;
}

#pragma mark - Lazy Initializer
- (TMMutableArrayWith(NSString *) *)identifiers
{
    if (_identifiers == nil)
    {
        _identifiers = [TMMutableArrayWith(NSString *) new];
    }
    return _identifiers;
}

- (TMMutableDictionaryWith(NSString *, NSNumber *) *)timeDataDic
{
    if (_timeDataDic == nil)
    {
        _timeDataDic = [TMMutableDictionaryWith(NSString *, NSNumber *) new];
    }
    return _timeDataDic;
}

#pragma mark - Public API
- (void)recordEventTime:(NSString *)eventName
{
#ifdef DEBUG
    NSString *keyName = [eventName copy];
    
    [self.identifiers addObject:keyName];
    [self.timeDataDic setObject:@(CACurrentMediaTime()) forKey:keyName];
#endif
}

- (void)printOutTimeProfileResult
{
#ifdef DEBUG
    for (NSString *eventName in self.identifiers) {
        NSAssert([self.timeDataDic objectForKey:eventName] != nil &&
                 [[self.timeDataDic objectForKey:eventName] isKindOfClass:[NSNumber class]], @"Save Wrong Type TimeStamp");
        
        CFTimeInterval current = [[self.timeDataDic objectForKey:eventName] doubleValue];
        printf("[%s] time stamp: %gms and execute for %gms -> \n", [eventName UTF8String], (current - self.recordStartTime) * 1000, (current - self.lastTime) * 1000);
        
        self.lastTime = current;
    }
#endif
}

- (void)saveTimeProfileDataIntoFile:(NSString *)fileName
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath =  [documentPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"txt"]];
    
    BHLog(@"TMTimeProfiler::SaveFilePath is %@", filePath);
    
    BOOL res=[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!res) {
        return;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];

    for (NSString *eventName in self.identifiers)
    {
        CFTimeInterval current = [[self.timeDataDic objectForKey:eventName] doubleValue];
        
        NSString *output = [NSString stringWithFormat:@"[%s] time stamp: %gms and execute for %gms -> \n", [eventName UTF8String],
                            (current - self.recordStartTime) * 1000,
                            (current - self.lastTime) * 1000];
        
        [handle writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.lastTime = current;
    }
    
    [handle closeFile];
    

}

- (void)postTimeProfileResultNotification
{
    NSMutableArray *logArray  = [NSMutableArray array];
    
    for (NSString *eventName in self.identifiers)
    {
        CFTimeInterval current = [[self.timeDataDic objectForKey:eventName] doubleValue];
        
        
        [logArray addObject: @{@"eventName":eventName,@"costTime": @((current - self.lastTime) * 1000)}];
        
        self.lastTime = current;
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:kTimeProfilerResultNotificationName object:nil userInfo:@{kNotificationUserInfoKey:logArray}];
}

@end
