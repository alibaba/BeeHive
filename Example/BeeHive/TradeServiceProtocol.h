//
//  TradeServiceProtocol.h
//  Pods
//
//  Created by 一渡 on 7/14/15.
//
//

#import <Foundation/Foundation.h>

#import "BHServiceProtocol.h"

@protocol TradeServiceProtocol <NSObject, BHServiceProtocol>


@property(nonatomic, strong) NSString *itemId;


@end
