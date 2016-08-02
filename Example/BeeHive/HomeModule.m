//
//  HomeModule.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "HomeModule.h"
#import "BeeHive.h"
#import "BHService.h"
#import "BHViewController.h"


@interface HomeModule()<BHModuleProtocol>

@end

@implementation HomeModule

-(void)modInit:(BHContext *)context
{
    switch (context.env) {
        case BHEnvironmentDev:
            //....初始化开发环境
            break;
        case BHEnvironmentProd:
            //....初始化生产环境
        default:
            break;
    }
}

- (void)modSetUp:(BHContext *)context
{
    NSLog(@"HomeModule setup");
}


@end
