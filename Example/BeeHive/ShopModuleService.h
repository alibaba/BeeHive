//
//  ShopTarget.h
//  BeeHive
//
//  Created by DP on 16/3/28.
//  Copyright © 2016年 一渡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopModuleService : NSObject

- (UIViewController *)nativeFetchDetailViewController:(NSDictionary *)params;
- (id)nativePresentImage:(NSDictionary *)params;
- (id)showAlert:(NSDictionary *)params;

// 容错
- (id)nativeNoImage:(NSDictionary *)params;

- (id)notFound:(NSDictionary *)params;


@end
