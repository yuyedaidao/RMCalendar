//
//  Helper.h
//  RMCalendar
//
//  Created by Wang on 15/8/4.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Helper : NSObject
+ (instancetype)defaultHelper;

@property (nonatomic, strong) User *user;

@end
