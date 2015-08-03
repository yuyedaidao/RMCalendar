//
//  YQDutyModel.h
//  RMCalendar
//
//  Created by 王叶庆 on 15/8/2.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YQDutyType) {
    YQDutyTypeWorkday,//平常（工作日）班
    YQDutyTypeWeekend,//周末班
};

@interface YQDutyModel : NSObject
/**
 *  年
 */
@property (nonatomic, assign) NSInteger year;
/**
 *  月
 */
@property (nonatomic, assign) NSInteger month;
/**
 *  日
 */
@property (nonatomic, assign) NSInteger day;

@property (nonatomic, assign) YQDutyType type;


/**
 *  早班人员，正常周末班也归到早班
 */
@property (nonatomic, strong) NSArray *morningUserArray;
/**
 *  晚班人员，或者周末班中的全天班
 */
@property (nonatomic, strong) NSArray *nightUserArray;

@end
