//
//  User.m
//  RMCalendar
//
//  Created by Wang on 15/8/4.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "User.h"

@implementation NSDictionary (User)

- (User *)userFromDictionary{
    User *user = [[User alloc] init];
    user.ID = [self[@"userid"] integerValue];
    user.name = self[@"realname"];
    user.account = self[@"username"];
    user.email = self[@"email"];
    return user;
}

@end

@implementation User

@end
