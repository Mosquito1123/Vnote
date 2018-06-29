//
//  CJLoginVC.m
//  百思不得姐
//
//  Created by ccj on 2017/5/8.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "CJLoginVC.h"
#import "CJMainVC.h"
#import "AppDelegate.h"
#import "CJMainNaVC.h"
@interface CJLoginVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *passwd;
@property (weak, nonatomic) IBOutlet UIButton *sendCode;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation CJLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    CJCornerRadius(self.loginBtn) = 5;
    CJCornerRadius(self.sendCode) = 5;
    CJCornerRadius(self.registerBtn) = 5;
    NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    if (email){
        self.email.text = email;
    }
    
    
}
- (IBAction)loginBtnClick:(UIButton *)sender {
    
    if (self.email.text.length && self.passwd.text.length){
        // 1.创建一个网络路径
        NSURL *url = [NSURL URLWithString:API_LOGIN];
        // 2.创建一个网络请求，分别设置请求方法、请求参数
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        NSDictionary *parms = @{@"email":self.email.text,@"passwd":self.passwd.text};
        NSData *data = [NSJSONSerialization dataWithJSONObject:parms options:NSJSONWritingPrettyPrinted error:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = data;
        // 3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                NSLog(@"%@",error);
            }
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
            NSLog(@"%@",dict[@"status"]);
            if ([dict[@"status"] intValue] == 0){
                // 保存账号和密码
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
                    [userD setValue:self.passwd.text forKey:@"passwd"];
                    [userD setValue:self.email.text forKey:@"email"];
                    [userD setValue:dict[@"nickname"] forKey:@"nickname"];
                    [userD synchronize];
                    AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
                    d.window.rootViewController = vc;
                    
                }];
            }
        }];
        [sessionDataTask resume];
    }
}
- (IBAction)registerBtnClick:(UIButton *)sender {
    
    
    //退出键盘
    [self.view endEditing:YES];
    if([[sender titleForState:UIControlStateNormal] isEqualToString:@"注册帐号"])
    {
    
        
        [sender setTitle:@"已有帐号" forState:UIControlStateNormal];
        self.leftMargin.constant=-CJScreenWidth;
        
    }
    else
    {
        [sender setTitle:@"注册帐号" forState:UIControlStateNormal];
        self.leftMargin.constant=0;
    
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
        //
        [self.view layoutIfNeeded];
    }];
    
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;
}


- (IBAction)closeBtnClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    //退出键盘
    [self.view endEditing:YES];
    
}



@end
