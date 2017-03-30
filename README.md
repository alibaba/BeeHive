# BeeHive

[![Build Status](https://travis-ci.org/alibaba/BeeHive.svg?branch=master)](https://travis-ci.org/alibaba/BeeHive)
[![Version](https://img.shields.io/cocoapods/v/BeeHive.svg?style=flat)](https://cocoapods.org/?q=name%3Abeehive)
[![Platform](https://img.shields.io/cocoapods/p/BeeHive.svg?style=flat)](https://cocoapods.org/?q=name%3Abeehive)
[![GitHub release](https://img.shields.io/github/release/alibaba/BeeHive.svg)](https://github.com/alibaba/BeeHive/releases)  
[![Gitter](https://badges.gitter.im/alibaba/BeeHive.svg)](https://gitter.im/alibaba/BeeHive?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![GitHub issues](https://img.shields.io/github/issues/alibaba/BeeHive.svg)](https://github.com/alibaba/BeeHive/issues)
[![License](https://img.shields.io/badge/license-GPL%20v2-4EB1BA.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

:book: English Documentation | [:book: 中文文档](README-CN.md)

<img src="http://gtms04.alicdn.com/tps/i4/TB1sc5IIFXXXXXOaXXXmZ78YFXX-1100-600.png_400x400.jpg" vspace="10px" align="right" >

--------------------------

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [0. Abstract](#0-abstract)
    - [0.1 The basic architecture](#01-the-basic-architecture)
    - [0.2 Core concepts](#02-core-concepts)
    - [0.3 Achieved characteristics](#03-achieved-characteristics)
    - [0.4 Design](#04-design)
    - [0.5 Project name origin](#05-project-name-origin)
- [1. Module life-cycle event](#1-module-life-cycle-event)
    - [1.1 System Event](#11-system-event)
    - [1.2 Universal Event](#12-universal-event)
    - [1.3 Business Custom Event](#13-business-custom-event)
- [2. Module registration](#2-module-registration)
    - [2.1 Static registration](#21-static-registration)
    - [2.2 Dynamic registration](#22-dynamic-registration)
    - [2.3 Asynchronous loading](#23-asynchronous-loading)
- [3. Programming](#3-programming)
    - [3.1 Setting environment variables](#31-setting-environment-variables)
    - [3.2 Module Init](#32-module-init)
    - [3.3 Event processing systems](#33-event-processing-systems)
    - [3.4 Inter-modal calls](#34-inter-modal-calls)
        - [3.4.1 Declare service interface](#341-declare-service-interface)
        - [3.4.2 Register Service](#342-register-service)
            - [API registration](#api-registration)
            - [`BHService.plist` registration](#bhserviceplist-registration)
        - [3.4.3 Service invocation](#343-service-invocation)
    - [3.5 Singleton or several instance](#35-singleton-or-several-instance)
    - [3.6 Global Context](#36-global-context)
- [4. Integration](#4-integration)
    - [`cocoapods`](#cocoapods)
- [5. Author](#5-author)
- [6. WeChat Group](#6-wechat-group)
- [7. License](#7-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# 0. Abstract

`BeeHive` is a modular program of implementation in iOS , it absorbed the Spring Framework API service concept to avoid to directly coupling between modules.

## 0.1 The basic architecture

We can get to know the architecture of BeeHive from this picture.

![](https://img.alicdn.com/tps/TB1k5u6LpXXXXc2XpXXXXXXXXXX-1968-1462.png)

## 0.2 Core concepts

- Module: Modules are separated by different function, every module can communicate with other one through their own services.
- Service: Services are the interface of the specifically module.

## 0.3 Achieved characteristics

* Plug-in module development of the operating framework
* Module implementation and interface calls Separation
* manage module life loop， extend the application of system events

## 0.4 Design

`BeeHive` bases on `Spring` Service concept, although you can make and implement specific interfaces decoupling between modules , but can not avoid interface class dependencies.

Why not use invoke and dynamic link library technology for decoupling interface , similar to `Apache`'s `DSO` way?

Mainly on account of the difficulty and cost of learning to achieve , and dynamic invocation interface parameters can not be able to check phase change problems at compile time , dynamic programming techniques require a higher threshold requirement.

## 0.5 Project name origin

`BeeHive` inspired by the honeycomb. `Honeycomb` is the world's highly modular engineering structures, hexagonal design can bring unlimited expansion possibilities. So we used to do for this project BeeHive named.

# 1. Module life-cycle event

BeeHive's Each module will provide life-cycle events for the host environment and Each module necessary information exchange to BeeHive, you can observer the change in life run loop.

Events are divided into three types:

* System Event
* Universal Event
* Business Custom Event

## 1.1 System Event

System events are usually Application life-cycle events , such as DidBecomeActive, WillEnterBackground etc.
System Event basic workflow is as follows:

![](https://img.alicdn.com/tps/TB1d_qQNFXXXXc3XVXXXXXXXXXX-1748-544.jpg)

## 1.2 Universal Event

On the basis of system events on the extended general application events , such modSetup, modInit , etc. , may be used to code each plug-in module initialization settings

Extended common events are as follows :

![](https://img.alicdn.com/tps/TB1jzGJNFXXXXabapXXXXXXXXXX-1840-552.jpg)

## 1.3 Business Custom Event

If you feel the system event , the event is not sufficient to meet the general needs , we will simplify the event packaged into BHAppdelgate, you can extend your own event by inheritance BHAppdelegate, while BHContext Lane modulesByName access each module entry class , to increase the trigger point through.

# 2. Module registration

Registration module divided into two types , static registration and dynamic registration

## 2.1 Static registration

![](http://gtms01.alicdn.com/tps/i1/TB114eDIFXXXXcdaXXX6VsMLVXX-998-334.png_400x400.jpg)

## 2.2 Dynamic registration

Use `BH_EXPORT_MODULE` macro module entry in the class implementation  declares the class for the
implementation class entry module

```
@implementation HomeModule

BH_EXPORT_MODULE(YES)

-(void)modInit:(BHContext *)context;

@end
```

## 2.3 Asynchronous loading

If the module is set to export BH_EXPORT_MODULE (YES), it will initialize asynchronous execution module can be optimized before starting after the first screen shows the contents of the start time consuming

# 3. Programming

`BHModuleProtocol` provides various modules each module can hook functions , and logic for implementing the plug-in code, you can fine protocol in `BHModuleProtocol.h`.

## 3.1 Setting environment variables

By context.env we can judge our application environment state to decide how we configure our application

```objc
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


## 3.2 Module Init

If the module there is need to start initialization logic can modInit in the preparation of , for example, the module can register an external module interface to access the Service

```objc
-(void)modInit:(BHContext *)context
{
	[[BeeHive shareInstance] registerService:@protocol(UserTrackServiceProtocol) service:[BHUserTrackViewController class]];
}
```

## 3.3 Event processing systems

Event system will be passed to each module, so that each module to decide to write business logic.


```objc
-(void)modQuickAction:(BHContext *)context
{
	[self process:context.shortcutItem handler:context.scompletionHandler];
}
```

## 3.4 Inter-modal calls

Event prepared by treating the various business modules can plug-in programming , it has no dependencies between the various business modules , through the interaction between the core and the event module, to achieve a plug-in isolation . But sometimes we need to call each other between modules some collaborative features to completion.

Usually in the form of three types to access service:

1. by interface(like `Spring`)
2. by `Export Method`(like `PHP`/`ReactNative` extension)
3. by `URL Route` pattern(like interaction between iPhone apps)

Interface type of service access can take the advantages of compile-time checking is found to change the interface , so that timely correction interface issues . The disadvantage is the need to rely on the interface definition header file by the module increases the more the maintenance interface definition there is a certain amount of work .

### 3.4.1 Declare service interface

Case thought HomeServiceProtocol:

```
@protocol HomeServiceProtocol <NSObject, BHServiceProtocol>

-(void)registerViewController:(UIViewController *)vc title:(NSString *)title iconName:(NSString *)iconName;

@end
```

### 3.4.2 Register Service

There are two ways to register ViewController Service.

#### API registration

```objc
[[BeeHive shareInstance] registerService:@protocol(HomeServiceProtocol) service:[BHViewController class]];
```

#### `BHService.plist` registration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>HomeServiceProtocol</key>
		<string>BHViewController</string>
	</dict>
</plist>

```

### 3.4.3 Service invocation

```objc
#import "BHService.h"

id< HomeServiceProtocol > homeVc = [[BeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];

// use homeVc do invocation
```

## 3.5 Singleton or several instance

For some scenes , we visit each declared as service objects , objects can hope to retain some of the state , then we need to declare this service object is a singleton object .

We only need to implement the function declaration in the event service objects

```objc
-(BOOL) singleton
{
	return YES;
}
```

The object was acquired by createService singleton object , if the function returns to achieve the above is NO, createService returns multiple cases

```objc
id< HomeServiceProtocol > homeVc = [[BeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];
```

## 3.6 Global Context

Initial setup application project information , and share information across applications among modules

```objc
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

# 4. Integration

## `cocoapods`

```sh
pod "BeeHive", '1.1.1'
```

# 5. Author

- [一渡](https://github.com/rexqin) shijie.qinsj\<at>alibaba-inc\<dot>com
- [达兹](https://github.com/SoXeon) dazi.dp\<at>alibaba-inc\<dot>com

# 6. WeChat Group

Because the WeChat Group had reached to the max number of people , you can join us by search dolphinux in WeChat.

# 7. License

BeeHive is available under the GPL license. See the LICENSE file for more info.
