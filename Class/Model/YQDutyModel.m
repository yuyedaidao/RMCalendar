//
//  YQDutyModel.m
//  RMCalendar
//
//  Created by 王叶庆 on 15/8/2.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "YQDutyModel.h"

@implementation YQDutyModel

- (DutyModel *)coreDataDutyModel{
    DutyModel *model = [[DutyModel alloc] init];
    model.year = @(self.year);
    model.month = @(self.month);
    model.day = @(self.day);
    
    model.userDutyType = @(self.userDutyType);
    model.type = @(self.type);
    
    model.morningUsers = self.morningUsers;
    model.nightUsers = self.nightUsers;
    
    return model;
}
@end
