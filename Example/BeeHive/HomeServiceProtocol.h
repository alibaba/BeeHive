//
//  HomeServiceProtocol.h
//  Pods
//
//  Created by 一渡 on 7/14/15.
//
//

#import <Foundation/Foundation.h>
#import "BHServiceProtocol.h"

@protocol HomeServiceProtocol <NSObject, BHServiceProtocol>


-(void)registerViewController:(UIViewController *)vc title:(NSString *)title iconName:(NSString *)iconName;

@end
