//
//  HSCoverView.m
//  HUB
//
//  Created by 王国栋 on 16/7/15.
//  Copyright © 2016年 xiaobai. All rights reserved.
//

#import "HSCoverView.h"
#import <UIKit/UIKit.h>
#import "Masonry.h"

static HSCoverView * single;
@interface HSCoverView ()

@property (nonatomic,strong) UILabel * titleLable;

@end
@implementation HSCoverView


+(instancetype)shareInstance
{
    if (single==nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            single = [[HSCoverView alloc]init];
        });
    }
    return single;
}
+(void)showMessage:(NSString *)title finishBlock:(void(^)())block
{
    if (single!= nil) {
      [single removeFromSuperview];
    }
    HSCoverView *covView =  [[HSCoverView alloc] init];
    single = covView;
    covView.titleLable.text = title;
    covView.alpha = 0;
    [covView showTheView];//finishBlock:block];
    CGRect rect = [title boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    [covView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(rect.size.width+20));
        make.height.equalTo(@(rect.size.height+10));
        make.left.equalTo(@((ZHWidth-rect.size.width-20)/2));
        make.top.equalTo(@(ZHHeight-rect.size.height-120));
    }];
    if (block!= nil) {
        block();
    }
}
-(void)showTheView//finishBlock:(void(^)())block
{
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    for (UIWindow  *window in frontToBackWindows ) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self];
            [self.superview bringSubviewToFront:self];
            [UIView animateWithDuration:1.5 animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished) {
                [self clooseTheView];//finishBlock:block];
            }];
        }
    }
}

-(void)clooseTheView//finishBlock:(void(^)())block
{
   [UIView animateWithDuration:1.5 animations:^{
       self.alpha = 0;
   } completion:^(BOOL finished) {
       [self removeTheView];//finishBlock:block];
   }];
    
}

-(void)removeTheView//finishBlock:(void(^)())block
{
   
    [self removeFromSuperview];
    
}

+(void)hideWithblock:(void(^)())block
{
    
    [UIView animateWithDuration:1.5 animations:^{
        single.titleLable.alpha = 0;
    } completion:^(BOOL finished) {
        
        [single removeFromSuperview];
        [single.titleLable removeFromSuperview];
        single.titleLable.text=@"";
        [single.titleLable removeConstraints:single.titleLable.constraints];
        if (block!=nil) {
            block();
        }
    }];
}

-(instancetype)init
{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        self.titleLable = [[UILabel alloc]init];
        self.titleLable.font = [UIFont systemFontOfSize:12];
        self.titleLable.textAlignment = NSTextAlignmentCenter;
        self.titleLable.textColor = [UIColor whiteColor];
        self.titleLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.titleLable.layer.cornerRadius = 5;
        self.titleLable.layer.masksToBounds = YES;
        [self addSubview:self.titleLable];
        [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(self);
        }];
    }
    return self;
}


@end
