//
//  CJAddAccountVC.m
//  VNote
//
//  Created by ccj on 2018/8/2.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAddAccountVC.h"

@interface CJAddAccountVC ()
@property (weak, nonatomic) IBOutlet UIButton *addAccountBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailL;
@property (weak, nonatomic) IBOutlet UITextField *passwdL;
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addAccountTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weNotelogoLeftMargin;

@end

@implementation CJAddAccountVC
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSMutableArray *)accounts{
    if (!_accounts){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _accounts = [NSMutableArray arrayWithArray:[userD objectForKey:ALL_ACCOUNT]];
        
    }
    return _accounts;
}

-(void)textChanged{
    self.addAccountBtn.enabled = self.emailL.text.length && self.passwdL.text.length;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CJCornerRadius(self.addAccountBtn) = 5;
    self.emailL.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.passwdL.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    [self.emailL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwdL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    self.addAccountBtn.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountNumNoti:) name:ACCOUNT_NUM_CHANGE_NOTI object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    self.weNotelogoLeftMargin.constant = 20.f;
    self.addAccountTopMargin.constant = 25.f;
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];
}
-(void)viewDidDisappear:(BOOL)animated{
    self.weNotelogoLeftMargin.constant = 100.f;
    self.addAccountTopMargin.constant = 100.f;
    [self.view layoutIfNeeded];
}

-(void)accountNumNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:ACCOUNT_NUM_CHANGE_NOTI]){
        self.accounts = nil;
        
    }
}

- (IBAction)addAccountClick:(id)sender {
    
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"添加中..." withImages:nil];

    NSString *email = self.emailL.text;
    NSString *passwd = self.passwdL.text;
    if (!email.length || !passwd.length){
        return;
    }
    for (NSDictionary *d in self.accounts) {
        if ([d[@"email"] isEqualToString:email]) {
            [hud cjShowError:@"账号已存在"];
            return;
            
        }
    }
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_LOGIN parameters:@{@"email":email,@"passwd":passwd} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        
        if ([dict[@"status"] intValue] == 0){
            
            [hud cjShowSuccess:@"添加成功"];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [CJTool catchAccountInfo2Preference:dict];
            NSNotification *noti = [NSNotification notificationWithName:ACCOUNT_NUM_CHANGE_NOTI object:nil];
            [[NSNotificationCenter defaultCenter]postNotification:noti];
        }
        else{
            [hud cjShowError:@"账号或密码错误!"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:net101code];
    }];
    
}


@end
