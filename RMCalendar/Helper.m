//
//  Helper.m
//  RMCalendar
//
//  Created by Wang on 15/8/4.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "Helper.h"
#import "Constants.h"

@implementation Helper
+ (instancetype)defaultHelper{
    static Helper *_helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[Helper alloc] init];
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KeyUserinfo];
        if(userInfo){
            _helper.user = [userInfo userFromDictionary];
        }
    });
    return _helper;
}
@end
