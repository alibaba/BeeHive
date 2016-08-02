//
//  ShopTarget.m
//  BeeHive
//
//  Created by DP on 16/3/28.
//  Copyright © 2016年 一渡. All rights reserved.
//

#import "ShopModuleService.h"
#import "ShopModuleViewController.h"

typedef void (^CTUrlRouterCallbackBlock)(NSDictionary *info);

@implementation ShopModuleService

- (UIViewController *)nativeFetchDetailViewController:(NSDictionary *)params
{
    // 因为action是从属于ModuleA的，所以action直接可以使用ModuleA里的所有声明
    ShopModuleViewController *viewController = [[ShopModuleViewController alloc] init];
    viewController.valueLabel.text = params[@"key"];
    return viewController;
}

- (id)nativePresentImage:(NSDictionary *)params
{
    ShopModuleViewController *viewController = [[ShopModuleViewController alloc] init];
    viewController.valueLabel.text = @"this is image";
    viewController.imageView.image = params[@"image"];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
    return nil;
}

- (id)showAlert:(NSDictionary *)params
{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        CTUrlRouterCallbackBlock callback = params[@"cancelAction"];
        if (callback) {
            callback(@{@"alertAction":action});
        }
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CTUrlRouterCallbackBlock callback = params[@"confirmAction"];
        if (callback) {
            callback(@{@"alertAction":action});
        }
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"alert from Module A" message:params[@"message"] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    return nil;
}

- (id)nativeNoImage:(NSDictionary *)params
{
    ShopModuleViewController *viewController = [[ShopModuleViewController alloc] init];
    viewController.valueLabel.text = @"no image";
    viewController.imageView.image = [UIImage imageNamed:@"noImage"];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
    
    return nil;
}

//如果没有找到对应Action，会走到这边


- (id)notFound:(NSDictionary *)params
{
    NSLog(@"sorry, we have find this action");
    return nil;
}

@end
