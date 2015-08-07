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
#import <DateTools.h>

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
    //TODO:考虑月份最后一天该怎么处理
//    [NSCalendar currentCalendar]
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:[@(components.year*10+components.month) stringValue]];
    if(array.count){
        
        NSDate *today = [NSDate date];
        __block YQDutyModel *model = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //TODO:优化这个可以考虑用数组下标访问，直接从今天开始处理
            [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                NSDate *futureDate = [NSDate dateWithString:obj[@"date"] formatString:@"yyyy-MM-dd"];
                if([futureDate isLaterThan:today]){
                    
                    NSString *morning = obj[@"zaoban"];
                    NSString *weekend = obj[@"zhoumoban"];
                    NSString *night = obj[@"wanban"];
                    
                    
                    UserDutyType userDutyType = UserDutyTypeDefault;
                    
                    if([weekend containsString:[Helper defaultHelper].user.name]){
                        userDutyType = UserDutyTypeWeekend;
                    }else if([night containsString:[Helper defaultHelper].user.name]){
                        userDutyType = UserDutyTypeNight;
                    }else if([morning containsString:[Helper defaultHelper].user.name]){
                        userDutyType = UserDutyTypeMorning;
                    }
                    
                    //查找一个最近的值班日期，如果是24之内查看有没有该本地通知，如果没有就添加通知
                    if(userDutyType != UserDutyTypeDefault){
                        
                        model = [[YQDutyModel alloc] init];
                        model.dutyStringDate = obj[@"date"];
                        NSArray *dateArray = [model.dutyStringDate componentsSeparatedByString:@"-"];
                        model.year = [dateArray[0] integerValue];
                        model.month = [dateArray[1] integerValue];
                        model.day = [dateArray[2] integerValue];
                        
                        *stop = YES;
                    }

                }
                
                
            }];
            
            if(model){
                NSInteger dutyIntDate = model.year*100+model.month*10+model.day;
                
                NSArray *localNotificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
                
                __block BOOL shouldNotification = YES;
                if (localNotificationArray) {
                    [localNotificationArray enumerateObjectsUsingBlock:^(UILocalNotification *obj, NSUInteger idx, BOOL *stop) {
                        NSDictionary *userInfo = obj.userInfo;
                        if(userInfo){
                            id value = userInfo[@"dutyDate"];
                            if([value integerValue] == dutyIntDate){
                                //说明找到了，不用再创建新的通知了
                                shouldNotification = NO;
                            }
                        }
                    }];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(shouldNotification){
                        
                        //如果现在已经晚上八点以后了就直接触发通知，如果还没到八点就八点再触发
//                        NSDate *dutyDate = [NSDate dateWithString:model.dutyStringDate formatString:@"yyyy-MM-dd"];
//                        NSDate *fireDate = [dutyDate dateByAddingHours:-4];
                        NSString *message = nil;
                        switch (model.userDutyType) {
                            case UserDutyTypeMorning:
                            {
                                message = @"少侠，明天有你的早班，切记，切记！";
                            }
                                break;
                            case UserDutyTypeWeekend:
                            {
                                message = @"明天是美好的周末，但是你却注定要值班！Come on!";
                            }
                                break;
                            case UserDutyTypeNight:
                            {
                                message = @"明天晚班，还是提前养好精神，洗洗睡吧！";
                            }
                                break;
                                
                            default:{
                                message  = @"没有值班，骗你呢";
                            
                            }
                                break;
                        }
                        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [[NSDate dateWithString:model.dutyStringDate formatString:@"yyyy-MM-dd"] dateByAddingHours:-4];
                        localNotification.timeZone = [NSTimeZone defaultTimeZone];
                        localNotification.alertBody = message;
                        //设置通知动作按钮的标题
                        localNotification.alertAction = @"查看";
                        //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
                        localNotification.soundName = UILocalNotificationDefaultSoundName;
                        //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
                        NSDictionary *infoDic = @{
                                                  @"dutyStringDate":model.dutyStringDate,
                                                  @"dutyDate":@(dutyIntDate)
                                                  };
                        localNotification.userInfo = infoDic;
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

                        if([UIApplication  sharedApplication].applicationState != UIApplicationStateBackground){
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"值班通知" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                });


            }
            
            
        });
    }

}
@end
