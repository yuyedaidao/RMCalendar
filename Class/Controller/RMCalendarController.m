//
//  RMCalendarController.m
//  RMCalendar
//
//  Created by 迟浩东 on 15/7/15.
//  Copyright © 2015年 迟浩东(http://www.ruanman.net). All rights reserved.
//

#import "RMCalendarController.h"
#import "RMCalendarCollectionViewLayout.h"
#import "RMCollectionCell.h"
#import "RMCalendarMonthHeaderView.h"
#import "RMCalendarLogic.h"
#import "LoginViewController.h"
#import <AFNetworking.h>
#import "Constants.h"
#import "LoginSegue.h"

#import <JSONKit.h>


/*
 [
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
 "zhoumoban": "殷爽爽,田衍虎,释君凯,肖伟,吴辉,黄磊",
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
 ]
 */

@interface RMCalendarController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation RMCalendarController

static NSString *MonthHeader = @"MonthHeaderView";

static NSString *DayCell = @"DayCell";

/**
 *  初始化模型数组对象
 */
- (NSMutableArray *)calendarMonth {
    if (!_calendarMonth) {
        _calendarMonth = [NSMutableArray array];
    }
    return _calendarMonth;
}

- (RMCalendarLogic *)calendarLogic {
    if (!_calendarLogic) {
        _calendarLogic = [[RMCalendarLogic alloc] init];
    }
    return _calendarLogic;
}


- (instancetype)initWithDays:(int)days showType:(CalendarShowType)type {
    self = [super init];
    if (!self) return nil;
    self.days = days;
    self.type = type;
    return self;
}


+ (instancetype)calendarWithDays:(int)days showType:(CalendarShowType)type {
    return [[self alloc] initWithDays:days showType:type];
}

- (void)awakeFromNib{

    self.days = 365;
    self.type = CalendarShowTypeSingle;
    self.displayChineseCalendar = YES;
    
}
- (void)setModelArr:(NSMutableArray *)modelArr {
#if __has_feature(objc_arc)
    _modelArr = modelArr;
#else
    if (_modelArr != modelArr) {
        [_modelArr release];
        _modelArr = [modelArr retain];
    }
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 定义Layout对象
    self.view.frame = [UIScreen mainScreen].bounds;
    
    
    RMCalendarCollectionViewLayout *layout = [[RMCalendarCollectionViewLayout alloc] init];
    // 初始化CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    
#if !__has_feature(objc_arc)
    [layout release];
#endif
    
    // 注册CollectionView的Cell
    [self.collectionView registerClass:[RMCollectionCell class] forCellWithReuseIdentifier:DayCell];
    
    [self.collectionView registerClass:[RMCalendarMonthHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MonthHeader];
    
    self.collectionView.delegate = self;//实现网格视图的delegate
    self.collectionView.dataSource = self;//实现网格视图的dataSource
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    UIImageView *bgImgView = [[UIImageView alloc] init];
    bgImgView.image = [UIImage imageNamed:@"morning"];
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImgView];
    self.collectionView.backgroundView = bgImgView;
    
    self.calendarMonth = [self getMonthArrayOfDays:self.days showType:self.type isEnable:self.isEnable modelArr:nil];
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [login setCompleteBlock:^{
        [self loadData];
    }];

    [self presentViewController:login animated:YES completion:nil];

}


- (void)loadData{
    
    NSInteger month = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:[NSDate date]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:[NSString stringWithFormat:@"%@%@&moth=%ld",BaseURL,zhibanMethod,month] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [result objectFromJSONString];
        if([dic[@"code"] integerValue] == 1){
            if(!self.dataArray){
                self.dataArray = [NSMutableArray array];
            }
            [self.dataArray removeAllObjects];
            
            NSArray *array = dic[@"details"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                    
                    
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
                    
                    NSArray *dateArray = [obj[@"date"] componentsSeparatedByString:@"-"];
                    model.year = [dateArray[0] integerValue];
                    model.month = [dateArray[1] integerValue];
                    model.day = [dateArray[2] integerValue];
                    
                    [self.dataArray addObject:model];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            });
            
            
            
        }else{
//            [[iToast makeText:@"数据错误"] show];
        }
        
      
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [[iToast makeText:@"网络错误"] show];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  获取Days天数内的数组
 *
 *  @param days 天数
 *  @param type 显示类型
 *  @param arr  模型数组
 *  @return 数组
 */
- (NSMutableArray *)getMonthArrayOfDays:(int)days showType:(CalendarShowType)type isEnable:(BOOL)isEnable modelArr:(NSArray *)arr
{
    NSDate *date = [NSDate date];
    
    NSDate *selectdate  = [NSDate date];
    //返回数据模型数组
    return [self.calendarLogic reloadCalendarView:date selectDate:selectdate needDays:days showType:type isEnable:isEnable modelArray:arr isChineseCalendar:self.isDisplayChineseCalendar];
}

#pragma mark - CollectionView 数据源

// 返回组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.calendarMonth.count;
}
// 返回每组行数
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *arrary = [self.calendarMonth objectAtIndex:section];
    return arrary.count;
}

#pragma mark - CollectionView 代理

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RMCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DayCell forIndexPath:indexPath];
    NSArray *months = [self.calendarMonth objectAtIndex:indexPath.section];
    RMCalendarModel *model = [months objectAtIndex:indexPath.row];
    if(indexPath.item < self.dataArray.count){
        model.dutyModel = self.dataArray[indexPath.item];
    }
    cell.model = model;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        NSMutableArray *month_Array = [self.calendarMonth objectAtIndex:indexPath.section];
        RMCalendarModel *model = [month_Array objectAtIndex:15];
        
        RMCalendarMonthHeaderView *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MonthHeader forIndexPath:indexPath];
        monthHeader.masterLabel.text = [NSString stringWithFormat:@"%lu年 %lu月",(unsigned long)model.year,(unsigned long)model.month];//@"日期";
        monthHeader.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
        reusableview = monthHeader;
    }
    return reusableview;
    
}

- (void)collectionView:(nonnull UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSArray *months = [self.calendarMonth objectAtIndex:indexPath.section];
    RMCalendarModel *model = [months objectAtIndex:indexPath.row];

    [self.calendarLogic selectLogic:model];
    if (self.calendarBlock) {
        self.calendarBlock(model);
    }
    [self.collectionView reloadData];
}

- (BOOL)collectionView:(nonnull UICollectionView *)collectionView shouldSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}


#pragma mark viewlife
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)dealloc {
#if !__has_feature(objc_arc)
    [self.collectionView release];
    [super dealloc];
#endif
}


@end
