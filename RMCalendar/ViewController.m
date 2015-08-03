//
//  ViewController.m
//  RMCalendar
//
//  Created by 迟浩东 on 15/7/1.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "ViewController.h"
#import "RMCalendarController.h"
#import "MJExtension.h"
#import "TicketModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnClick {
    // CalendarShowTypeMultiple 显示多月
    // CalendarShowTypeSingle   显示单月
    RMCalendarController *c = [RMCalendarController calendarWithDays:365 showType:CalendarShowTypeSingle];

    // 是否展现农历
    c.isDisplayChineseCalendar = YES;
    
    // YES 没有价格的日期可点击
    // NO  没有价格的日期不可点击
    c.isEnable = YES;
    c.title = @"值班表";
    c.calendarBlock = ^(RMCalendarModel *model) {
        
    };
    [self.navigationController pushViewController:c animated:YES];
}

@end
