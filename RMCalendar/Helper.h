//
//  Helper.h
//  RMCalendar
//
//  Created by Wang on 15/8/4.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <AFNetworking.h>
/*
 
 {
 "details": [
 {
 "date": "2015-08-01",
 "zaoban": "",
 "zhoumoban": "刘瑄,魏志奇,栗端沛,谷默,杜震霖,王叶庆",
 "wanban": "谷默,栗端沛"
 },
 {
 "date": "2015-08-02",
 "zaoban": "",
 "zhoumoban": "孙超,田衍虎,梁丽娟,孙俊,尹鹏吉",
 "wanban": "孙超,田衍虎"
 },
 {
 "date": "2015-08-03",
 "zaoban": "解品喜,王叶庆",
 "zhoumoban": "",
 "wanban": "翟术亮,李长彬"
 },
 {
 "date": "2015-08-04",
 "zaoban": "栗端沛,殷爽爽",
 "zhoumoban": "",
 "wanban": "吴辉,田衍虎"
 },
 {
 "date": "2015-08-05",
 "zaoban": "魏志奇,王璐",
 "zhoumoban": "",
 "wanban": "解品喜,卢方伟"
 },
 {
 "date": "2015-08-06",
 "zaoban": "马淼,姚隆华",
 "zhoumoban": "",
 "wanban": "孙超,李龙"
 },
 {
 "date": "2015-08-07",
 "zaoban": "孙超,尹鹏吉",
 "zhoumoban": "",
 "wanban": "魏志奇,杜震霖"
 },
 {
 "date": "2015-08-08",
 "zaoban": "",
 "zhoumoban": "谢长亮,解品喜,孙俊,郭丽萍,杨建,卢方伟",
 "wanban": "孙俊,杨建"
 },
 {
 "date": "2015-08-09",
 "zaoban": "",
 "zhoumoban": "孙超,田衍虎,释君凯,肖伟,吴辉,黄磊",
 "wanban": "释君凯,肖伟"
 },
 {
 "date": "2015-08-10",
 "zaoban": "孙超,王璐",
 "zhoumoban": "",
 "wanban": "谷默,栗端沛"
 },
 {
 "date": "2015-08-11",
 "zaoban": "翟术亮,李长彬",
 "zhoumoban": "",
 "wanban": "孙俊,杨建"
 },
 {
 "date": "2015-08-12",
 "zaoban": "肖伟,郭丽萍",
 "zhoumoban": "",
 "wanban": "魏志奇,杜震霖"
 },
 {
 "date": "2015-08-13",
 "zaoban": "康凯,尚鲁杰",
 "zhoumoban": "",
 "wanban": "翟术亮,李龙"
 },
 {
 "date": "2015-08-14",
 "zaoban": "卢方伟,谢长亮",
 "zhoumoban": "",
 "wanban": "孙俊,杨建"
 },
 {
 "date": "2015-08-15",
 "zaoban": "",
 "zhoumoban": "翟术亮,郝盛,李龙,曾南,俞海波,任靖怡",
 "wanban": "俞海波,曾南"
 },
 {
 "date": "2015-08-16",
 "zaoban": "",
 "zhoumoban": "何双,马淼,魏素雅,王璐,姚隆华,尚鲁杰",
 "wanban": "马淼,姚隆华"
 },
 {
 "date": "2015-08-17",
 "zaoban": "栗端沛,殷爽爽",
 "zhoumoban": "",
 "wanban": "翟术亮,李龙"
 },
 {
 "date": "2015-08-18",
 "zaoban": "卢方伟,谢长亮",
 "zhoumoban": "",
 "wanban": "俞海波,曾南"
 },
 {
 "date": "2015-08-19",
 "zaoban": "田衍虎,谷默",
 "zhoumoban": "",
 "wanban": "解品喜,卢方伟"
 },
 {
 "date": "2015-08-20",
 "zaoban": "马淼,姚隆华",
 "zhoumoban": "",
 "wanban": "吴辉,田衍虎"
 },
 {
 "date": "2015-08-21",
 "zaoban": "翟术亮,李长彬",
 "zhoumoban": "",
 "wanban": "释君凯,肖伟"
 },
 {
 "date": "2015-08-22",
 "zaoban": "",
 "zhoumoban": "孙超,李长彬,梁丽娟,康凯,尹鹏吉",
 "wanban": "康凯,尹鹏吉"
 },
 {
 "date": "2015-08-23",
 "zaoban": "",
 "zhoumoban": "刘瑄,魏志奇,栗端沛,谷默,杜震霖,王叶庆",
 "wanban": "魏志奇,杜震霖"
 },
 {
 "date": "2015-08-24",
 "zaoban": "李龙,俞海波",
 "zhoumoban": "",
 "wanban": "孙超,李长彬"
 },
 {
 "date": "2015-08-25",
 "zaoban": "释君凯,刘瑄",
 "zhoumoban": "",
 "wanban": "谷默,栗端沛"
 },
 {
 "date": "2015-08-26",
 "zaoban": "孙俊,郝盛",
 "zhoumoban": "",
 "wanban": "释君凯,肖伟"
 },
 {
 "date": "2015-08-27",
 "zaoban": "杨建,吴辉",
 "zhoumoban": "",
 "wanban": "康凯,尹鹏吉"
 },
 {
 "date": "2015-08-28",
 "zaoban": "杜震霖,何双",
 "zhoumoban": "",
 "wanban": "马淼,姚隆华"
 },
 {
 "date": "2015-08-29",
 "zaoban": "",
 "zhoumoban": "殷爽爽,李长彬,释君凯,肖伟,吴辉,杨建",
 "wanban": "吴辉,李长彬"
 },
 {
 "date": "2015-08-30",
 "zaoban": "",
 "zhoumoban": "任靖怡,解品喜,康凯,郭丽萍,黄磊,卢方伟",
 "wanban": "解品喜,卢方伟"
 },
 {
 "date": "2015-08-31",
 "zaoban": "李龙,俞海波",
 "zhoumoban": "",
 "wanban": "康凯,尹鹏吉"
 }
 ],
 "code": 1
 }
 */
@interface Helper : NSObject
+ (instancetype)defaultHelper;

@property (nonatomic, strong) User *user;
- (void)backUpdate;
- (void)backUpdateWithBlock:(void (^)(void))completeBlock;
- (void)checkDuty;
/**
 *  明天是不是下个月的第一天
 *
 *  @return 
 */
+ (BOOL)isNextMonthOfDate:(NSDate *)date;
- (void)loadDutyScheduleWhithSuccess:(void (^)(NSInteger code, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
