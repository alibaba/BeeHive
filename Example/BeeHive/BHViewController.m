//
//  BHViewController.m
//  BeeHive
//
//  Created by 一渡 on 07/10/2015.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "BHViewController.h"

#import "BeeHive.h"
#import "BHService.h"

@BeeHiveService(HomeServiceProtocol,BHViewController)
@interface BHViewController ()<HomeServiceProtocol>

@property(nonatomic,strong) NSMutableArray *registerViewControllers;

@end

@interface demoTableViewController : UIViewController


@end


@implementation BHViewController

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.registerViewControllers = [[NSMutableArray alloc] initWithCapacity:1];
        
        demoTableViewController *v1 = [[demoTableViewController alloc] init];
        if ([v1 isKindOfClass:[UIViewController class]]) {
            [self registerViewController:v1 title:@"埋点" iconName:nil];
        }
        
        id<UserTrackServiceProtocol> v4 = [[BeeHive shareInstance] createService:@protocol(UserTrackServiceProtocol)];
        if ([v4 isKindOfClass:[UIViewController class]]) {
            [self registerViewController:(UIViewController *)v4 title:@"埋点3" iconName:nil];
        }
        
        
        id<TradeServiceProtocol> v2 = [[BeeHive shareInstance] createService:@protocol(TradeServiceProtocol)];
        if ([v2 isKindOfClass:[UIViewController class]]) {
            v2.itemId = @"sdfsdfsfasf";
            [self registerViewController:(UIViewController *)v2 title:@"交易2" iconName:nil];
        }
        
        
        
            id<TradeServiceProtocol> s2 = (id<TradeServiceProtocol>)[[BeeHive shareInstance] createService:@protocol(TradeServiceProtocol)];
            
            
            if ([s2 isKindOfClass:[UIViewController class]]) {
                s2.itemId = @"例子222222";
                [self registerViewController:(UIViewController *)s2 title:@"交易3" iconName:nil];
            }
    
        
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    sleep(1);


}

-(void)registerViewController:(UIViewController *)vc title:(NSString *)title iconName:(NSString *)iconName
{
    vc.tabBarItem.image = [UIImage imageNamed:[NSString stringWithFormat:@"Home.bundle/%@", iconName]];
    vc.tabBarItem.title = title;
    
    [self.registerViewControllers addObject:vc];
    
    self.viewControllers = self.registerViewControllers;
}


-(void)click:(UIButton *)btn
{
 
    id<TradeServiceProtocol> obj = [[BeeHive shareInstance] createService:@protocol(TradeServiceProtocol)];
    if ([obj isKindOfClass:[UIViewController class]]) {
        obj.itemId = @"12313231231";
        [self.navigationController pushViewController:(UIViewController *)obj animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@implementation demoTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
@end
