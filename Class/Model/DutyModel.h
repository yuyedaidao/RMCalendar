//
//  DutyModel.h
//  RMCalendar
//
//  Created by Wang on 15/8/5.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DutyModel : NSManagedObject

@property (nonatomic, retain) NSString * morningUsers;
@property (nonatomic, retain) NSString * nightUsers;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userDutyType;

@property (nonatomic, strong) NSArray *morningUserArray;
@property (nonatomic, strong) NSArray *nightUserArray;

@end
