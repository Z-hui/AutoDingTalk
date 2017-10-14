//
//  TimeTableViewController.m
//  AutoDingTalk
//
//  Created by HSEDU on 2017/9/5.
//  Copyright © 2017年 Zhui. All rights reserved.
//

#import "TimeTableViewController.h"
#import "PushInfoViewController.h"
#import "DTimeTableModel.h"

@interface TimeTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *timeArray;
@end

@implementation TimeTableViewController

-(NSMutableArray *)timeArray
{
    if (_timeArray == nil) {
        _timeArray = [NSMutableArray array];
    }
    return _timeArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [UILabel new];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
        make.height.mas_equalTo(30);
    }];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = @"推送时间列表";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *addbtn = [UIButton new];
    [self.view addSubview:addbtn];
    [addbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [addbtn setImage:[UIImage imageNamed:@"addImage"] forState:(UIControlStateNormal)];
    [addbtn addTarget:self action:@selector(addPushAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    UITableView *tableView = [[UITableView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addbtn.mas_bottom).offset(10);
        make.left.right.bottom.equalTo(self.view);
    }];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.tableFooterView = [UIView new];
    
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadNewData];
    }];
    
    // Do any additional setup after loading the view.
}
-(void)loadNewData
{
    [DNetTool Post:@"index/pushList" param:nil success:^(NSDictionary *responseObject) {
        self.timeArray = [DTimeTableModel mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        [self.tableView reloadData];
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
    } failure:^(NSError *error) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)addPushAction{
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:PUSHMESSAGE];
    if (array.count>=6) {
        [HSCoverView showMessage:@"推送数量已达上限" finishBlock:nil];
        return;
    }
    PushInfoViewController *infoVC = [[PushInfoViewController alloc] initWithNibName:@"PushInfoViewController" bundle:nil];
    [self presentViewController:infoVC animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView.mj_header beginRefreshing];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cell"];
    }
    DTimeTableModel *model = self.timeArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"【%@】:%@",model.push_time,model.content];
    cell.detailTextLabel.text = model.content;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  55;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PushInfoViewController *infoVC = [[PushInfoViewController alloc] initWithNibName:@"PushInfoViewController" bundle:nil];
    infoVC.DtModel = self.timeArray[indexPath.row];
    [self presentViewController:infoVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
