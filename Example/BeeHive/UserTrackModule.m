//
//  UserTrackModule.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "UserTrackModule.h"

#import "BeeHive.h"
#import "BHService.h"

#import "BHUserTrackViewController.h"

@interface UserTrackModule()<BHModuleProtocol>

@end

@implementation UserTrackModule


BH_EXPORT_MODULE(NO)

- (void)modSetUp:(BHContext *)context
{
    NSLog(@"UserTrackModule setup");
}



-(void)modInit:(BHContext *)context
{

//    [[BeeHive shareInstance] registerService:@protocol(UserTrackServiceProtocol) service:[BHUserTrackViewController class]];
}

@end
