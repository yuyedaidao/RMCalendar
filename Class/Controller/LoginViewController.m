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
#import "User.h"
#import "Helper.h"
#import <UICKeyChainStore.h>
#import <UITextField+Shake.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (strong, nonatomic) UIImageView *bgImgView;
@property (strong, nonatomic) UIView *effectView;

@end

@implementation LoginViewController


- (void)loadView{
    [super loadView];
    
    self.bgImgView = ({
        UIImageView *bgImgView = [[UIImageView alloc] init];
        bgImgView.image = [UIImage imageNamed:@"morning"];
        bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:bgImgView];
        bgImgView;
    });
    
    
    self.effectView = ({
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self.view addSubview:effectView];
        effectView;
    });
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.frame = [UIScreen mainScreen].bounds;
  
    self.effectView.frame = self.view.bounds;
    self.bgImgView.frame = self.view.bounds;
    [self.view sendSubviewToBack:self.effectView];
    [self.view sendSubviewToBack:self.bgImgView];
}


#pragma mark action
- (IBAction)login:(id)sender {
    
    if(self.userNameTF.text.length <= 0){
        [self.userNameTF shake];
        return;
    }
    if(self.passwordTF.text.length <= 0){
        [self.passwordTF shake];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
  
    [manager POST:[NSString stringWithFormat:@"%@%@",BaseURL,LoginMethod] parameters:@{@"user":self.userNameTF.text,@"pass":self.passwordTF.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
        if([result containsString:@"title=\"Sign Out\">退出</a>"]){
            
            //把用户名和密码锁起来
            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KeyChainService];
            keychain[KeyChainPassword] = self.passwordTF.text;
            keychain[keyChainAccount] = self.userNameTF.text;

            //应该先获取用户信息，然后再退出视图
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            //    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
            [manager GET:[NSString stringWithFormat:@"%@%@",BaseURL,UserinfoMethod] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSDictionary *dic = [result objectFromJSONString];
                if([dic[@"code"] integerValue] == 1){
                    [[NSUserDefaults standardUserDefaults] setObject:dic[@"userinfo"] forKey:KeyUserinfo];
                    [Helper defaultHelper].user = [dic[@"userinfo"] userFromDictionary];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self dismiss];
                    [hud hide:YES];
                }else{
//                                [[iToast makeText:@"数据错误"] show];
                    [hud hide:YES];
                }
                
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
//                [[iToast makeText:@"网络错误"] show];
                [hud hide:YES];
            }];

        }else{
            [[iToast makeText:@"登录失败"] show];
            [hud hide:YES];
        }

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error == %@",error);
        [[iToast makeText:@"网络错误"] show];
        [hud hide:YES];
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
