//
//  LoginViewController.m
//  RMCalendar
//
//  Created by Wang on 15/8/3.
//  Copyright (c) 2015年 迟浩东. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <iToast.h>
#import <JSONKit.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

#pragma mark action
- (IBAction)login:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
  
    [manager POST:[NSString stringWithFormat:@"%@%@",BaseURL,LoginMethod] parameters:@{@"user":self.userNameTF.text,@"pass":self.passwordTF.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
       
        if([result containsString:@"title=\"Sign Out\">退出</a>"]){
            //应该先获取用户信息，然后再退出视图
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            //    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
            [manager GET:[NSString stringWithFormat:@"%@%@",BaseURL,UserinfoMethod] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSDictionary *dic = [result objectFromJSONString];
                if([dic[@"code"] integerValue] == 1){
                    [[NSUserDefaults standardUserDefaults] setObject:dic[@"userinfo"] forKey:KeyUserinfo];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self dismiss];
                }else{
                    //            [[iToast makeText:@"数据错误"] show];
                }
                
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"error = =%@",error);
                //        [[iToast makeText:@"网络错误"] show];
            }];

        }else{
            [[iToast makeText:@"登录失败"] show];
        }

        [hud hide:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[iToast makeText:@"网络错误"] show];
    }];
}

- (void)dismiss{

    if(self.completeBlock){
        self.completeBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
