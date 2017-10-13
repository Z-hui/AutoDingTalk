//
//  ViewController.m
//  AutoDingTalk
//
//  Created by HSEDU on 2017/8/31.
//  Copyright © 2017年 Zhui. All rights reserved.
//

#import "ViewController.h"
#import "MainViewController.h"
#import "TimeTableViewController.h"


//nal_unit_type: 1, nal_ref_idc: 2
#define  ZHWidth [UIScreen mainScreen].bounds.size.width
#define  ZHHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property (nonatomic,strong)UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initBaseUI];
    
}

-(void)initBaseUI{

    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.scrollView.contentSize = CGSizeMake(2*ZHWidth, 0);
    self.scrollView.bounces = NO;
    
    MainViewController *main = [MainViewController new];
    main.view.frame = CGRectMake(0, 0, ZHWidth, ZHHeight);
    [self.scrollView addSubview:main.view];
    [self addChildViewController:main];

    TimeTableViewController *timeVC = [TimeTableViewController new];
    timeVC.view.frame = CGRectMake(ZHWidth, 0, ZHWidth, ZHHeight);
    [self.scrollView addSubview:timeVC.view];
    [timeVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(main.view);
        make.left.equalTo(main.view.mas_right);
        make.size.mas_equalTo(CGSizeMake(ZHWidth, ZHHeight));
    }];
    [self addChildViewController:timeVC];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
