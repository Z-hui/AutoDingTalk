//
//  YYDataPicker.h
//  PickView
//
//  Created by Yong on 16/9/9.
//  Copyright © 2016年 Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DateBlock)(NSString *dateString);

/** 点击代理 */
@protocol selectDataPickerDelegate <NSObject>

- (void)passValue:(NSString *)dateString;

@end

@interface YYDataPicker : UIView

@property (weak, nonatomic)id<selectDataPickerDelegate> delegate;

/** 确认按钮颜色 默认灰色*/
@property (strong, nonatomic) UIColor *sureColor;
/** 取消按钮颜色 默认灰色*/
@property (strong, nonatomic) UIColor *cancleColor;
/** 按钮所在视图颜色 默认灰色*/
@property (strong, nonatomic) UIColor *buttonViewColor;
/** 选择器时间模式 */
@property (assign, nonatomic) UIDatePickerMode dataPickMode;

@property (copy, nonatomic) DateBlock dateBlock;

+ (instancetype)dataPickerWithModel:(UIDatePickerMode)dataPickMode Delegate:(id<selectDataPickerDelegate>)delegate;
/** 回调传值 */
- (void)passDateValue:(DateBlock)block;

@end
