//
//  TodayViewController.m
//  TodayDutyExtension
//
//  Created by 王叶庆 on 15/8/8.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
//#import "Helper.h"
#import "YQDutyModel.h"

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextDutyLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *userName = @"wangyq";
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    //TODO:考虑月份最后一天该怎么处理
    //    [NSCalendar currentCalendar]
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:[@(components.year*10+components.month) stringValue]];
    
    for (NSInteger i = components.day; i < array.count; i++) {
        NSDictionary *obj = array[i];
        
        YQDutyModel *model = [[YQDutyModel alloc] init];
        
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
        if([weekend containsString:userName]){
            model.userDutyType = UserDutyTypeWeekend;
        }else if([night containsString:userName]){
            model.userDutyType = UserDutyTypeNight;
        }else if([morning containsString:userName]){
            model.userDutyType = UserDutyTypeMorning;
        }else{
            model.userDutyType = UserDutyTypeDefault;
        }
        
        NSArray *dateArray = [obj[@"date"] componentsSeparatedByString:@"-"];
        model.year = [dateArray[0] integerValue];
        model.month = [dateArray[1] integerValue];
        model.day = [dateArray[2] integerValue];
        
        if(model.userDutyType != UserDutyTypeDefault){
            if(i == components.day){
                //今天
                switch (model.userDutyType) {
                    case UserDutyTypeMorning:
                        self.todayLabel.text = @"早班";
                        break;
                    case UserDutyTypeNight:
                        self.todayLabel.text = @"晚班";
                        break;
                    case UserDutyTypeWeekend:
                        self.todayLabel.text = @"周末班";
                        break;
                    default:
                        self.todayLabel.text = @"不值班";
                        break;
                }
            }else{
                switch (model.userDutyType) {
                    case UserDutyTypeMorning:
                        self.nextDutyLabel.text = [NSString stringWithFormat:@"%ld月%ld日 早班",(long)model.month,(long)model.day];
                        break;
                    case UserDutyTypeNight:
                        self.nextDutyLabel.text = [NSString stringWithFormat:@"%ld月%ld日 晚班",(long)model.month,(long)model.day];;
                        break;
                    case UserDutyTypeWeekend:
                        self.nextDutyLabel.text = [NSString stringWithFormat:@"%ld月%ld日 周末班",(long)model.month,(long)model.day];;
                        break;
                    default:
                        self.nextDutyLabel.text = @"我还不知道";
                        break;
                }
                break;
            }
            
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
