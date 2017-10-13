//
//  YYDataPicker.m
//  PickView
//
//  Created by Yong on 16/9/9.
//  Copyright © 2016年 Yong. All rights reserved.
//

#import "YYDataPicker.h"

#define PICKER_HIGHT 200
#define BUTTON_VIEW_HEIGHT 45
#define PICKER_PUSH_TIME 0.3

@interface YYDataPicker()
{
    UIView *_btnView;
    UIButton *_sureBtn;
    UIButton *_cancleBtn;
}
@property (nonatomic, strong) UIDatePicker *datePicker;
//  容器视图
@property (nonatomic, strong) UIView *pushView;

@property (nonatomic, strong) UIButton *maskbtn;
@end

@implementation YYDataPicker

+ (instancetype)dataPickerWithModel:(UIDatePickerMode)dataPickMode Delegate:(id<selectDataPickerDelegate>)delegate{

    YYDataPicker *dataPicker = [[self alloc]init];
    dataPicker.delegate = delegate;
    dataPicker.dataPickMode = dataPickMode;

    return dataPicker;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
        self.backgroundColor = [UIColor clearColor];

        [self customDataPicker];
        [self initialize];
    }
    return self;
}
- (void)initialize{

    self.buttonViewColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    self.sureColor = [UIColor colorWithRed:93/255.0 green:93/255.0 blue:93/255.0 alpha:1];
    self.cancleColor = [UIColor colorWithRed:93/255.0 green:93/255.0 blue:93/255.0 alpha:1];
    self.dataPickMode = UIDatePickerModeDateAndTime;
}

- (void)customDataPicker
{
    // 半透明蒙版
    UIButton *maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.maskbtn = maskBtn;
    maskBtn.frame = self.bounds;
    maskBtn.backgroundColor = [UIColor blackColor];
    maskBtn.alpha = 0;
    [maskBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:maskBtn];
    
    [UIView animateWithDuration:1 animations:^{
        maskBtn.alpha = 0.35;
    }];

    //  放picker和Btn的容器
    CGRect rect = self.frame;
    self.pushView = [[UIView alloc]initWithFrame:CGRectMake( 0, rect.size.height, rect.size.width, PICKER_HIGHT + BUTTON_VIEW_HEIGHT)];
    self.pushView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.pushView];
    //  放Btn的容器
    _btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.pushView.frame.size.width, BUTTON_VIEW_HEIGHT)];
    _btnView.backgroundColor = _buttonViewColor;
    [self.pushView addSubview:_btnView];

    CGFloat padding = 20;
    CGFloat btnWidth = 40;
    CGFloat btnHeight = 30;
    CGFloat btnY = (BUTTON_VIEW_HEIGHT - btnHeight)/2;

    _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancleBtn.frame = CGRectMake(padding, btnY, btnWidth, btnHeight);
    [_cancleBtn setTitleColor:_cancleColor forState:UIControlStateNormal];
    [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancleBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [_btnView addSubview:_cancleBtn];

    _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureBtn.frame = CGRectMake(rect.size.width-padding-btnWidth, btnY, btnWidth, btnHeight);
    [_sureBtn setTitleColor:_sureColor forState:UIControlStateNormal];
    [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    _sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [_btnView addSubview:_sureBtn];


    self.datePicker = [[UIDatePicker alloc]init];
    //  设置地区
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    //  设置日期的模式
    self.datePicker.datePickerMode = _dataPickMode;

    self.datePicker.frame = CGRectMake(0, btnHeight, rect.size.width, PICKER_HIGHT);
    [self.pushView addSubview:self.datePicker];

    [self pushPickerView];
}
//  弹出动画
- (void)pushPickerView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:PICKER_PUSH_TIME animations:^{
        weakSelf.pushView.frame = CGRectMake(0, weakSelf.frame.size.height - PICKER_HIGHT - BUTTON_VIEW_HEIGHT,weakSelf.frame.size.width , PICKER_HIGHT + BUTTON_VIEW_HEIGHT);
    }];
}

- (void)closeAction
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:PICKER_PUSH_TIME animations:^{
        weakSelf.pushView.frame = CGRectMake( 0, weakSelf.frame.size.height, weakSelf.frame.size.width, PICKER_HIGHT + BUTTON_VIEW_HEIGHT);
        weakSelf.maskbtn.alpha = 0;

    } completion:^(BOOL finished) {
        [weakSelf.pushView removeFromSuperview];
        [weakSelf.datePicker removeFromSuperview];
        [weakSelf removeFromSuperview];
    }];

}
- (void)sureAction
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@" HH:mm "];
   // [dateFormatter setTimeStyle:<#(NSDateFormatterStyle)#>]
    
    NSString *dateStr = [dateFormatter stringFromDate:self.datePicker.date];

    if ([self.delegate respondsToSelector:@selector(passValue:)]) {
        [self.delegate passValue:dateStr];
    }
    if (self.dateBlock) {
        self.dateBlock(dateStr);
    }
    
    [self closeAction];
}
- (void)passDateValue:(DateBlock)block{

    self.dateBlock = block;
}
#pragma mark setting
- (void)setSureColor:(UIColor *)sureColor{
    _sureColor = sureColor;
    [_sureBtn setTitleColor:sureColor forState:UIControlStateNormal];

}
- (void)setCancleColor:(UIColor *)cancleColor{
    _cancleColor = cancleColor;
    [_cancleBtn setTitleColor:cancleColor forState:UIControlStateNormal];

}

- (void)setButtonViewColor:(UIColor *)buttonViewColor{
    _buttonViewColor = buttonViewColor;
    _btnView.backgroundColor = buttonViewColor;

}
- (void)setDataPickMode:(UIDatePickerMode)dataPickMode{
    _dataPickMode = dataPickMode;
    self.datePicker.datePickerMode = dataPickMode;
}

@end
