//
//  PushInfoViewController.m
//  AutoDingTalk
//
//  Created by HSEDU on 2017/9/5.
//  Copyright © 2017年 Zhui. All rights reserved.
//

#import "PushInfoViewController.h"
#import "YYDataPicker.h"
#import "DNetTool.h"

@interface PushInfoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *timeSetBtn;
@property (weak, nonatomic) IBOutlet UITextField *titleField;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong)NSString *selectTime;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic,strong)NSMutableDictionary *pushMessage;
@end

@implementation PushInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.pushMessage = [[NSMutableDictionary alloc] init];
    self.deleteBtn.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.DtModel != nil) {
        self.titleLabel.text = @"编辑推送";
        self.deleteBtn.hidden = NO;
        self.titleField.text = self.DtModel.content;
        [self.timeSetBtn setTitle:self.DtModel.push_time forState:(UIControlStateNormal)];
    }
}

- (IBAction)setPushTimeAction:(id)sender {
    [self.view endEditing:YES];
    YYDataPicker *dataPicker = [YYDataPicker dataPickerWithModel:UIDatePickerModeTime Delegate:nil];
    [dataPicker passDateValue:^(NSString *dateString) {
        self.selectTime = dateString;
        [self.timeSetBtn setTitle:dateString forState:(UIControlStateNormal)];
    }];
}
- (IBAction)deleteAction:(id)sender {
   
    [DNetTool Post:@"index/delPush" param:@{@"uid":self.DtModel.uid} success:^(NSDictionary *responseObject) {
        
    } failure:^(NSError *error) {
        
    }];
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)completeAction:(id)sender {
    
    if (self.titleField.text.length>0) {
        [self.pushMessage setObject:self.titleField.text forKey:@"content"];
    }
    else
    {
        [HSCoverView showMessage:@"请输入标题" finishBlock:nil];
        return;
    }
    
    if (self.selectTime.length>0) {
        [self.pushMessage setObject:self.selectTime forKey:@"push_time"];
    }
    else
    {
        [HSCoverView showMessage:@"请选择时间" finishBlock:nil];
        return;
    }

    if (self.DtModel != nil) {
        [self.pushMessage setObject:self.DtModel.uid forKey:@"uid"];
    }
    [DNetTool Post:@"index/editPush" param:self.pushMessage success:^(NSDictionary *responseObject) {
       [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        
    }];

   
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
