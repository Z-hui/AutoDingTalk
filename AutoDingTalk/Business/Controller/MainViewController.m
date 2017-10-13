//
//  MainViewController.m
//  AutoDingTalk
//
//  Created by HSEDU on 2017/9/5.
//  Copyright © 2017年 Zhui. All rights reserved.
//


#import "MainViewController.h"

#import "FSCalendar.h"
#import "DIYCalendarCell.h"
#import "FSCalendarExtensions.h"

#define MaxPushCount 60

@interface MainViewController () <FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>
@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) UIButton *openDingTalk;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSMutableArray *selectDates;
@property (strong, nonatomic) NSString *nextday;
- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
@end

@implementation MainViewController

-(NSMutableArray *)selectDates
{
    if (_selectDates == nil) {
        _selectDates = [NSMutableArray array];
    }
    return _selectDates;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor whiteColor];//[UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    [self creatCaledarUI];
    
    UIButton *label = [[UIButton alloc] initWithFrame:CGRectMake((ZHWidth-100)/2, CGRectGetMaxY(self.calendar.frame)+40, 100, 100)];
    [self.view addSubview:label];
    self.openDingTalk = label;
    [self.openDingTalk setBackgroundImage:[UIImage imageNamed:@"openBtnImage.jpg"] forState:(UIControlStateNormal)];
    [self.openDingTalk setTitle:@"打开钉钉" forState:(UIControlStateNormal)];
    self.openDingTalk.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.openDingTalk addTarget:self action:@selector(openDingTalkAction:) forControlEvents:(UIControlEventTouchUpInside)];
}
-(void)creatCaledarUI{
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.allowsMultipleSelection = YES;
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
    calendar.calendarHeaderView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    calendar.calendarWeekdayView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    calendar.appearance.eventSelectionColor = [UIColor whiteColor];
    calendar.appearance.eventOffset = CGPointMake(0, -7);
    calendar.today = nil; // Hide the today circle
    [calendar registerClass:[DIYCalendarCell class] forCellReuseIdentifier:@"cell"];
    
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
}
-(void)reloadCalendarView{
    [self calendarCancleAllSelectDate];
    [self loadNewdata];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendarView) name:@"RELOADCALENDAR" object:nil];
    
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
    [self loadNewdata];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadCalendarView];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RELOADCALENDAR" object:nil];
}
-(void)loadNewdata
{
    
    
    if (self.calendar.selectedDates.count >0 ) {
        [self calendarCancleAllSelectDate];
        return;
    }
   
 
    [DNetTool Post:@"select/date" param:nil success:^(NSDictionary *responseObject) {
        
        self.selectDates = responseObject[@"list"];
        for (NSString *date in self.selectDates) {
            [self.calendar selectDate:[self.dateFormatter dateFromString:date] scrollToDate:NO];
        }
        [self.calendar reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
    
    
    [SVProgressHUD dismiss];
}
- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

-(BOOL)MoreThanDateCompareToNowTime:(NSString *)dateString{
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:PUSHMESSAGE];
    
    for (NSDictionary *dict in array) {
        
        NSString *timeString = dict[@"time"];
        NSString *goalDate = [NSString stringWithFormat:@"%@ %@",dateString,timeString];
        
        NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
        [dateformater setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *currentdate = [NSDate date];
        NSDate *dtb = [[NSDate alloc] init];
        
        dtb = [dateformater dateFromString:goalDate];
        NSComparisonResult result = [currentdate compare:dtb];
        if (result==NSOrderedSame)
        {
            //[HSCoverView showMessage:@"=" finishBlock:nil];
            //相等
        }else if (result==NSOrderedAscending)
        {
           // [HSCoverView showMessage:@"big" finishBlock:nil];
            //bDate比aDate大
             return YES;
        }else if (result==NSOrderedDescending)
        {
           // [HSCoverView showMessage:@"small" finishBlock:nil];
            //bDate比aDate小
           
        }
        
    }
    
    return NO;
}

-(NSString *)timeIntervalFromDate:(NSDate*)date
{
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)timeSp];
    return timeStr;
}
#pragma 打开DingTalk
- (void)openDingTalkAction:(id)sender {
    
    NSLog(@"%@",self.selectDates);
    //[self registerNotification10:@""];
   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"DingTalk://fdsafsf"]];
}


#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [NSDate date];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:5 toDate:[NSDate date] options:0];
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    DIYCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition
{
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    return 2;
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    
  //  self.openDingTalk.frame = CGRectMake(0, CGRectGetMaxY(calendar.frame)+10, self.view.frame.size.width, 50);
    
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        
        return YES;
    }
    return NO;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionCurrent;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);

    [self configureVisibleCells];
    [DNetTool Post:@"date/select" param:@{@"date":[self.dateFormatter stringFromDate:date]} success:^(NSDictionary *responseObject) {

    
    } failure:^(NSError *error) {
        
    }];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did deselect date %@",[self.dateFormatter stringFromDate:date]);

    [self configureVisibleCells];
    
    [DNetTool Post:@"date/deselect" param:@{@"date":[self.dateFormatter stringFromDate:date]} success:^(NSDictionary *responseObject) {
        
        
        
    } failure:^(NSError *error) {
        
    }];
  
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

#pragma mark - Private methods

- (void)configureVisibleCells
{
    [self.calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.calendar dateForCell:obj];
        FSCalendarMonthPosition position = [self.calendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    
    DIYCalendarCell *diyCell = (DIYCalendarCell *)cell;
    
    // Custom today circle
    diyCell.circleImageView.hidden = ![self.gregorian isDateInToday:date];
    
    // Configure selection layer
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        
        SelectionType selectionType = SelectionTypeNone;
        if ([self.calendar.selectedDates containsObject:date]) {
            NSDate *previousDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:date options:0];
            NSDate *nextDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
            if ([self.calendar.selectedDates containsObject:date]) {
                if ([self.calendar.selectedDates containsObject:previousDate] && [self.calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeMiddle;
                } else if ([self.calendar.selectedDates containsObject:previousDate] && [self.calendar.selectedDates containsObject:date]) {
                    selectionType = SelectionTypeRightBorder;
                } else if ([self.calendar.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeLeftBorder;
                } else {
                    selectionType = SelectionTypeSingle;
                }
            }
        } else {
            selectionType = SelectionTypeNone;
        }
        
        if (selectionType == SelectionTypeNone) {
            diyCell.selectionLayer.hidden = YES;
            return;
        }
        
        diyCell.selectionLayer.hidden = NO;
        diyCell.selectionType = selectionType;
        
    } else {
        
        diyCell.circleImageView.hidden = YES;
        diyCell.selectionLayer.hidden = YES;
        
    }
}
-(void)calendarCancleAllSelectDate
{
    for (NSDate *date  in self.calendar.selectedDates) {
        [self.calendar deselectDate:date];
    }
    [self.calendar reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 //清空所有本地推送
 [[UIApplication sharedApplication] cancelAllLocalNotifications];
 
 //检测过期推送及获取已设置推送的最大时间戳
 NSInteger maxInterVal = 0;
 if (self.cacheDate.count>0) {
 for (NSString *date in self.cacheDate.allKeys) {
 
 if (![self MoreThanDateCompareToNowTime:self.cacheDate[date][@"date"]]) {
 NSMutableDictionary *overdue = [self.cacheDate[date] mutableCopy];
 overdue[@"status"] = @"NoSelect";
 [self.cacheDate setObject:overdue forKey:date];
 }
 if ([date integerValue]>maxInterVal) {
 maxInterVal = [date integerValue];
 }
 }
 }
 else
 {
 if ([self MoreThanDateCompareToNowTime:[self.dateFormatter stringFromDate:[NSDate date]]]) {
 maxInterVal = [[self timeIntervalFromDate:[NSDate dateWithTimeInterval:60*60*24*(-1) sinceDate:[NSDate date]]] integerValue];
 }
 else{
 maxInterVal = [[self timeIntervalFromDate:[NSDate date]] integerValue];
 }
 
 }
 
 //检测有效推送数量
 NSInteger validCount = 0;
 for (NSDictionary *dateDict in self.cacheDate.allValues) {
 if ([dateDict[@"status"] isEqualToString:@"Select"]) {
 validCount ++;
 }
 }
 
 //如果当前设置的推送数量小于60增加新推送
 NSInteger day = 1;
 NSString *maxDay = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:maxInterVal]];
 if (validCount*array.count<MaxPushCount&&array.count>0) {
 do {
 NSDate *nextDat = [NSDate dateWithTimeInterval:60*60*24*day sinceDate:[self.dateFormatter dateFromString:maxDay]];//后一天
 if ([[self weekdayStringFromDate:nextDat] isEqualToString:@"星期六"]||[[self weekdayStringFromDate:nextDat] isEqualToString:@"星期天"]) {
 NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 [dict setObject:[self.dateFormatter stringFromDate:nextDat] forKey:@"date"];
 [dict setObject:@"NoSelect" forKey:@"status"];
 [self.cacheDate setObject:dict forKey:[self timeIntervalFromDate:nextDat]];
 }
 else
 {
 NSLog(@"next:%@",[self.dateFormatter stringFromDate:nextDat]);
 
 NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 [dict setObject:[self.dateFormatter stringFromDate:nextDat] forKey:@"date"];
 [dict setObject:@"Select" forKey:@"status"];
 [self.cacheDate setObject:dict forKey:[self timeIntervalFromDate:nextDat]];
 validCount ++;
 }
 day++;
 } while (validCount*array.count<MaxPushCount);
 }
 
 //重新设置推送
 if (array.count>0) {
 for (NSDictionary *dateDict in self.cacheDate.allValues) {
 NSString *date = dateDict[@"date"];
 if ([dateDict[@"status"] isEqualToString:@"Select"]) {
 [self.calendar selectDate:[self.dateFormatter dateFromString:date] scrollToDate:NO];
 if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
 [self registerNotification10:date];
 }
 else
 {
 [self registerLocalNotification:date];
 }
 }
 }
 [self.calendar reloadData];
 }
 */
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
