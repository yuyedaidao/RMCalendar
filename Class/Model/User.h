//
//  User.h
//  RMCalendar
//
//  Created by Wang on 15/8/4.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface NSDictionary (User)
- (User *)userFromDictionary;
@end

@interface User : NSObject
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@end
