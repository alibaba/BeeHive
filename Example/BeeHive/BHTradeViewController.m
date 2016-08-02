//
//  BHTradeViewController.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "BHTradeViewController.h"
#import "BeeHive.h"


@implementation BHTradeViewController

@synthesize itemId=_itemId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-100, 0, 200, 300)];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@", self.itemId];
    
    [self.view addSubview:label];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-50,
                                                               CGRectGetMaxY(label.frame)-20,
                                                               100,
                                                               80)];
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn.backgroundColor = [UIColor blackColor];
    
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}



-(void)click:(UIButton *)btn
{
    
    id<TradeServiceProtocol> obj = [[BeeHive shareInstance] createService:@protocol(TradeServiceProtocol)];
    if ([obj isKindOfClass:[UIViewController class]]) {
        obj.itemId = @"12313231231";
        [self.navigationController pushViewController:(UIViewController *)obj animated:YES];
    }
}


@end
