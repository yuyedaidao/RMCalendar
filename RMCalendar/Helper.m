//
//  Helper.m
//  RMCalendar
//
//  Created by Wang on 15/8/4.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "Helper.h"
#import "Constants.h"
#import <AFNetworking.h>
#import <JSONKit.h>
#import <UICKeyChainStore.h>
#import "YQDutyModel.h"

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
- (void)backUpdateWithBlock:(void (^)(void))completeBlock{
    
    if(completeBlock){

        NSInteger performCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"performCount"];
        [[NSUserDefaults standardUserDefaults] setInteger:performCount+1 forKey:@"performCount"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KeyChainService];
    NSString *password = keychain[KeyChainPassword];
    NSString *account = keychain[keyChainAccount];
    if(password.length && account.length){
        [manager POST:[NSString stringWithFormat:@"%@%@",BaseURL,LoginMethod] parameters:@{@"user":account,@"pass":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if([result containsString:@"title=\"Sign Out\">退出</a>"]){
               
                //获取用户信息
                AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
                manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                //    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
                [manager1 GET:[NSString stringWithFormat:@"%@%@",BaseURL,UserinfoMethod] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *result1 = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSDictionary *dic1 = [result1 objectFromJSONString];
                    if([dic1[@"code"] integerValue] == 1){
                     
                        [[NSUserDefaults standardUserDefaults] setObject:dic1[@"userinfo"] forKey:KeyUserinfo];
                        [Helper defaultHelper].user = [dic1[@"userinfo"] userFromDictionary];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        //获取值班信息
                        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
                        AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
                        manager2.responseSerializer = [AFHTTPResponseSerializer serializer];
                        
                        [manager2 GET:[NSString stringWithFormat:@"%@%@&moth=%ld",BaseURL,zhibanMethod,components.month] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSString *result2 = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                            
                            NSDictionary *dic2 = [result2 objectFromJSONString];
                            if([dic2[@"code"] integerValue] == 1){
                             
                                NSArray *array = dic2[@"details"];
                                if(array.count){
                                    [[NSUserDefaults standardUserDefaults] setObject:array forKey:[@(components.year*10+components.month) stringValue]];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    [[Helper defaultHelper] checkDuty];
                                }
                                
                            }else{
                                //            [[iToast makeText:@"数据错误"] show];
                            }
                            
                            if(completeBlock){
                                completeBlock();
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                        NSLog(@"error duty = %@",error);
                            //        [[iToast makeText:@"网络错误"] show];
                            if(completeBlock){
                                completeBlock();
                            }
                        }];

                        
                        
                    }else{
                        //获取用户信息失败
                        if(completeBlock){
                            completeBlock();
                        }
                    }
                    
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                NSLog(@"%@",error);
                    //获取用户 网络错误
                    if(completeBlock){
                        completeBlock();
                    }
                }];
                
            }else{
    //            NSLog(@"登录失败 %@",result);
                if(completeBlock){
                    completeBlock();
                }
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //        NSLog(@"%@",error);
            if(completeBlock){
                completeBlock();
            }
        }];
    }

}
- (void)backUpdate{
    [self backUpdateWithBlock:nil];
}

- (void)checkDuty{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:[@(components.year*10+components.month) stringValue]];
    if(array.count){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                
                YQDutyModel *model = [[YQDutyModel alloc] init];
                //                    DutyModel *model = [[DutyModel alloc] init];
                
                NSString *morning = obj[@"zaoban"];
                NSString *weekend = obj[@"zhoumoban"];
                NSString *night = obj[@"wanban"];
                if(weekend.length){
                    model.type = YQDutyTypeWeekend;
                    model.morningUserArray = [weekend componentsSeparatedByString:@","];
                }else{
                    model.type = YQDutyTypeWorkday;
                    model.morningUserArray = [morning componentsSeparatedByString:@","];
                }
                model.nightUserArray = [night componentsSeparatedByString:@","];
                if([weekend containsString:[Helper defaultHelper].user.name]){
                    model.userDutyType = UserDutyTypeWeekend;
                }else if([night containsString:[Helper defaultHelper].user.name]){
                    model.userDutyType = UserDutyTypeNight;
                }else if([morning containsString:[Helper defaultHelper].user.name]){
                    model.userDutyType = UserDutyTypeMorning;
                }else{
                    model.userDutyType = UserDutyTypeDefault;
                }
                
                NSArray *dateArray = [obj[@"date"] componentsSeparatedByString:@"-"];
                model.year = [dateArray[0] integerValue];
                model.month = [dateArray[1] integerValue];
                model.day = [dateArray[2] integerValue];
                
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //                    [[Helper defaultHelper] checkDuty];
            });
        });
    }

}
@end
