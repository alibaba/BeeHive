/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface BHConfig : NSObject

+ (instancetype)shareInstance;

+ (id)get:(NSString *)key;

+ (BOOL)has:(NSString *)key;

+ (void)add:(NSDictionary *)parameters;

+ (NSMutableDictionary *)getAll;

+ (NSString *)stringValue:(NSString *)key;

+ (NSDictionary *)dictionaryValue:(NSString *)key;

+ (NSInteger)integerValue:(NSString *)key;

+ (float)floatValue:(NSString *)key;

+ (BOOL)boolValue:(NSString *)key;

+ (NSArray *)arrayValue:(NSString *)key;

+ (void)set:(NSString *)key value:(id)value;

+ (void)set:(NSString *)key boolValue:(BOOL)value;

+ (void)set:(NSString *)key integerValue:(NSInteger)value;

+ (void)clear;

@end
