//
//  AppUISkeletonServiceProtocol.h
//  AppUISkeleton
//
//  Created by 宵练 on 7/17/15.
//  Copyright (c) 2015 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHServiceProtocol.h"

@protocol AppUISkeletonServiceProtocol <NSObject, BHServiceProtocol>

- (UIViewController *)mainViewController;

@end
