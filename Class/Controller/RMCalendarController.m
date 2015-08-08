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
#import <MJRefresh.h>
#import <JSONKit.h>
#import "Helper.h"
#import <UICKeyChainStore.h>
#import "DutyModel.h"
#import <Masonry.h>
#import <ReactiveCocoa.h>
#import <Reachability.h>
#import <DateTools.h>

@interface RMCalendarController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIImageView *bgImgView;
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

    self.title = @"值班表";
    self.view.frame = [UIScreen mainScreen].bounds;
    
    [self prepareCollectionView];
    [self prepareView];
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KeyChainService];
    if(keychain[KeyChainPassword].length){
        [self loadData];
    }else{
        [self loginView];
    }

}

#pragma mark selector
- (void)logout:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要退出吗?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    
    [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
        if([x integerValue] == 0){
            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KeyChainService];
            [keychain removeItemForKey:KeyChainPassword];
            [self loginView];
        }
    }];
    
    [alert show];
    

}

#pragma mark self handler

- (void)loginView{
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [login setCompleteBlock:^{
        [self loadData];
    }];
    
    [self presentViewController:login animated:YES completion:nil];
}
- (void)prepareView{
    
    
    self.bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    bgImgView.image = [UIImage imageNamed:@"morning"];
    self.bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.bgImgView];
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
    [logout setTitle:@"退出" forState:UIControlStateNormal];
    [logout setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    logout.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 5);
    [logout addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logout];
    
    [logout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-30));
        make.trailing.equalTo(@(-30));
    }];
    
    
}
- (void)prepareCollectionView{
    
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
//    self.collectionView.backgroundView = self.view;
//    self.collectionView.backgroundColor = [UIColor clearColor];
   
    self.calendarMonth = [self getMonthArrayOfDays:self.days showType:self.type isEnable:self.isEnable modelArr:nil];
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadDataFromNet];
    }];
   

}

- (void)loadDataFromNet{
   
    [[Helper defaultHelper] loadDutyScheduleWhithSuccess:^(NSInteger code, id responseObject) {
        if(code == 1){
            NSArray *array = responseObject;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self wrapData:array];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.calendarMonth = [self getMonthArrayOfDays:self.days showType:self.type isEnable:self.isEnable modelArr:self.dataArray];
                    [self.collectionView reloadData];
                    [self.collectionView.header endRefreshing];
                    
                    [[Helper defaultHelper] checkDuty];
                });
            });

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[Helper defaultHelper] checkDuty];
    }];

}
- (void)loadData{
    
    //先从本地获取数据 然后再去网络获取
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    NSArray *oldArray = [[NSUserDefaults standardUserDefaults] objectForKey:[@(components.year*10+components.month) stringValue]];
    if(oldArray){
        [self wrapData:oldArray];
        self.calendarMonth = [self getMonthArrayOfDays:self.days showType:self.type isEnable:self.isEnable modelArr:self.dataArray];
        [self.collectionView reloadData];
    }
    
    [self loadDataFromNet];
    
}
- (void)wrapData:(NSArray *)array{
    if(!self.dataArray){
        self.dataArray = [NSMutableArray array];
    }
    [self.dataArray removeAllObjects];
    
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
        
        [self.dataArray addObject:model];
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
