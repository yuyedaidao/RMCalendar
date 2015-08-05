//
//  Constants.m
//  RMCalendar
//
//  Created by Wang on 15/8/3.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *BaseURL = @"http://10.0.117.203/";
static NSString *LoginMethod = @"auth/doLogin";
static NSString *zhibanMethod = @"zhiban/api.php?action=getSchedule";
static NSString *UserinfoMethod = @"zhiban/api.php?action=getUserInfo";

static NSString *KeyUserinfo = @"keyUserInfo";
static NSString *KeyChainPassword = @"password";
static NSString *keyChainAccount = @"account";
static NSString *KeyChainService = @"com.iqilu.token";

static NSTimeInterval IntervalBackgroundFetchData = 60*60*4;