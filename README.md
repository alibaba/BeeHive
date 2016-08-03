# BeeHive

[![Version](https://img.shields.io/cocoapods/v/BeeHive.svg?style=flat)](http://cocoapods.org/pods/BeeHive)
[![License](https://img.shields.io/cocoapods/l/BeeHive.svg?style=flat)](http://cocoapods.org/pods/BeeHive)
[![Platform](https://img.shields.io/cocoapods/p/BeeHive.svg?style=flat)](http://cocoapods.org/pods/BeeHive)

##1. Abstract

BeeHive is a modular program of implementation in iOS , it absorbed the Spring Framework API service concept to avoid to directly coupling between modules.

##2. The basic principle is as follows:
![](http://gtms02.alicdn.com/tps/i2/TB1dhyFIFXXXXavaXXX7jjbSFXX-515-233.jpg_400x400.jpg)


##3. Achieved the following characteristics:

* Plug-in module development of the operating framework
* Module implementation and interface calls Separation
* manage module life loop， extend the application of system events

BeeHive bases on Spring Service concept, although you can make and implement specific interfaces decoupling between modules , but can not avoid interface class dependencies.

Why not use invoke and dynamic link library technology for decoupling interface , similar to Apache 's DSO way?

Mainly on account of the difficulty and cost of learning to achieve , and dynamic invocation interface parameters can not be able to check phase change problems at compile time , dynamic programming techniques require a higher threshold requirement.

BeeHive inspired by the honeycomb . Honeycomb is the world's highly modular engineering structures, hexagonal design can bring unlimited expansion possibilities. So we used to do for this project BeeHive named.


## 4.Observer the change in life run loop 
### 1. Event
BeeHive's Each module will provide life-cycle events for the host environment and Each module necessary information exchange to BeeHive.
Events are divided into three types:

* System Event
* Universal Event
* Business Custom Event

#### System Event
System events are usually Application life-cycle events , such as DidBecomeActive, WillEnterBackground etc.
System Event basic workflow is as follows:
![](http://gtms01.alicdn.com/tps/i1/TB1OrsXIFXXXXaoXFXXjWC18pXX-1119-552.jpg) 

#### Universal Event
On the basis of system events on the extended general application events , such modSetup, modInit , etc. , may be used to code each plug-in module initialization settings

Extended common events are as follows :
![](http://gtms04.alicdn.com/tps/i4/TB1lOH5IFXXXXX6XVXXZJGkYVXX-1523-552.jpg) 

####  Business Custom Event

If you feel the system event , the event is not sufficient to meet the general needs , we will simplify the event packaged into BHAppdelgate, you can extend your own event by inheritance BHAppdelegate, while BHContext Lane modulesByName access each module entry class , to increase the trigger point through.

### 5. Module register
Registration module divided into two types , static registration and dynamic registration

* static registration：
 
  ![](http://gtms01.alicdn.com/tps/i1/TB114eDIFXXXXcdaXXX6VsMLVXX-998-334.png_400x400.jpg)
* dynamic registration：

Use BH_EXPORT_MODULE macro module entry in the class implementation  declares the class for the
implementation class entry module

```""
@implementation HomeModule

BH_EXPORT_MODULE(YES)

-(void)modInit:(BHContext *)context;
```

* Asynchronous loading

If the module is set to export BH_EXPORT_MODULE (YES), it will initialize asynchronous execution module can be optimized before starting after the first screen shows the contents of the start time consuming

### 6. Programming
BHModuleProtocol provides various modules each module can hook functions , and logic for implementing the plug-in code, you can fine protocol in BHModuleProtocol.h

Setting environment variables

By context.env we can judge our application environment state to decide how we configure our application

```
-(void)modSetup:(BHContext *)context
{
	switch (context.env) {
		case BHEnvironmentDev:
		break;
		case BHEnvironmentProd:
		default:
		break;
	}
}
```


*  Module Init

If the module there is need to start initialization logic can modInit in the preparation of , for example, the module can register an external module interface to access the Service

```
-(void)modInit:(BHContext *)context
{
	[[BeeHive shareInstance] registerService:@protocol(UserTrackServiceProtocol) service:[BHUserTrackViewController class]];
}
```

* Event processing systems
  
  
Event system will be passed to each module , so that each module to decide to write business logic


```
-(void)modQuickAction:(BHContext *)context
{
	[self process:context.shortcutItem handler:context.scompletionHandler];
}
```


### 7. Inter-modal calls

Event prepared by treating the various business modules can plug-in programming , it has no dependencies between the various business modules , through the interaction between the core and the event module, to achieve a plug-in isolation . But sometimes we need to call each other between modules some collaborative features to completion.
Usually in the form of three types of interface to access

	
### 8. Servcie access
Service can access the advantages of compile-time checking is found to change the interface , so that timely correction interface issues . The disadvantage is the need to rely on the interface definition header file by the module increases the more the maintenance interface definition there is a certain amount of work . Case thought HomeServiceProtocol

```""
@protocol HomeServiceProtocol <NSObject, BHServiceProtocol>

-(void)registerViewController:(UIViewController *)vc title:(NSString *)title iconName:(NSString *)iconName;

@end

```
 there three ways to registe Service
 
 * Declarative registration
 
   ```
	@implementation HomeService

	BH_EXPORT_SERVICE()

	```
	
 * API registration
 
   ```""
[[BeeHive shareInstance] registerService:@protocol(HomeServiceProtocol) service:[BHViewController class]];
```
* BHService.plist registration

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>HomeServiceProtocol</key>
<string>BHViewController</string>
</dict>
</plist>

```
* transfer

```

#import "BHService.h"

id< HomeServiceProtocol > homeVc = [[BeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];

```

#### Singleton or several instance
For some scenes , we visit each declared as service objects , objects can hope to retain some of the state , then we need to declare this service object is a singleton object .

We only need to implement the function declaration in the event service objects

```
-(BOOL) singleton
{
	return YES;
}

```
The object was acquired by createService singleton object , if the function returns to achieve the above is NO, createService returns multiple cases

```
id< HomeServiceProtocol > homeVc = [[BeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];
```
## Global Context

Initial setup application project information , and share information across applications among modules

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	[BHContext shareInstance].env ＝ BHEnvironmentDev; 
	
	[BHContext shareInstance].application = application;
	[BHContext shareInstance].launchOptions = launchOptions;
	
	[BHContext shareInstance].moduleConfigName = @"BeeHive.bundle/CustomModulePlist";
	[BHContext shareInstance].serviceConfigName =  @"BeeHive.bundle/CustomServicePlist";
	
	[BHContext shareInstance].appkey  = xxxxxx;
	[BHContext shareInstance].Mtopkey  = xxxxx;
	
	
	[[BeeHive shareInstance] setContext:[BHContext shareInstance]];
	
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
	
	id<HomeServiceProtocol> homeVc = [[BeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];
	
	
	if ([homeVc isKindOfClass:[UIViewController class]]) {
	UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:(UIViewController*)homeVc];
	
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = navCtrl;
	
	[self.window makeKeyAndVisible];
}

return YES;
}
```
## Integrated approach
* use cocoapods 

pod "BeeHive", '1.0.0'

## author

一渡, shijie.qinsj@alibaba-inc.com

达兹, dazi.dp@alibaba-inc.com

## License

BeeHive is available under the GPL license. See the LICENSE file for more info.


