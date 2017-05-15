/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "BHWatchDog.h"
#import "BHCommon.h"
#import <UIKit/UIKit.h>

typedef void (^handler)();
typedef void (^watchdogFiredCallBack)();


@interface PingThread : NSThread

@property (nonatomic, assign) double threshold;
@property (nonatomic, assign) BOOL   pingTaskIsRunning;
@property (nonatomic, copy)   handler handler;

@end

@implementation PingThread

- (instancetype)initWithThreshold:(double)threshold handler:(handler)handler
{
    if (self = [super init]) {
        self.pingTaskIsRunning = NO;
        self.threshold = threshold;
        self.handler = handler;
    }

    return self;
}

- (void)main
{
   dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    while (!self.cancelled) {
        self.pingTaskIsRunning = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pingTaskIsRunning = NO;
            dispatch_semaphore_signal(semaphore);
        });
    
        [NSThread sleepForTimeInterval:self.threshold];
        if (self.pingTaskIsRunning) {
            self.handler();
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end

@interface BHWatchDog()


@property (nonatomic, assign) double threshold;
@property (nonatomic, strong) PingThread *pingThread;

@end

@implementation BHWatchDog

- (instancetype)initWithThreshold:(double)threshold strictMode:(BOOL)strictMode
{
    self = [self initWIthThreshold:threshold callBack:^() {
        NSString *message = [NSString stringWithFormat:@"👮 Main thread was blocked 👮"];
        if (strictMode) {
            //避免后台切换导致进入断言
            NSAssert([UIApplication sharedApplication].applicationState == UIApplicationStateBackground, message);
        } else {
            BHLog(@"%@", message);
        }
    }];

    return self;
}


- (instancetype)initWIthThreshold:(double)threshold callBack:(watchdogFiredCallBack)callBack
{
    if (self = [self init]) {
        self.threshold = 0.4;//默认间隔
        self.threshold = threshold;
        self.pingThread = [[PingThread alloc] initWithThreshold:threshold handler:callBack];
        [self.pingThread start];
    }
   
    return self;
}


- (void)dealloc
{
    [self.pingThread cancel];
}

@end


