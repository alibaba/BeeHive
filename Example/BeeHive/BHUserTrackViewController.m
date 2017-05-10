//
//  BHUserTrackViewController.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "BHUserTrackViewController.h"

#import "BeeHive.h"

#import "BHService.h"
@BeeHiveService(UserTrackServiceProtocol,BHUserTrackViewController)
@interface BHUserTrackViewController()<UserTrackServiceProtocol>


@end


@implementation BHUserTrackViewController

+(BOOL)singleton
{
    return NO;
}

@end
