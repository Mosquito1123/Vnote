//
//  CJChangeNicknameVC.m
//  VNote
//
//  Created by ccj on 2018/8/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJChangeNicknameVC.h"

@interface CJChangeNicknameVC ()
@property (weak, nonatomic) IBOutlet UITextField *nicknameT;

@end

@implementation CJChangeNicknameVC
-(void)textChange{
    CJUser *user = [CJUser sharedUser];
    self.navigationItem.rightBarButtonItem.enabled = self.nicknameT.text.length;
    if ([user.nickname isEqualToString:self.nicknameT.text]){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"更改昵称";
    [self.nicknameT addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    CJUser *user = [CJUser sharedUser];
    self.nicknameT.text = user.nickname;
    
}
-(void)done{
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"更改中..." withImages:nil];
    CJUser *user = [CJUser sharedUser];
    NSString *text = self.nicknameT.text;
    [CJAPI changeNicknameWithParams:@{@"email":user.email,@"nickname":text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"更改成功"];
        user.nickname = text;
        [CJTool catchAccountInfo2Preference:[user toDic]];
        [[NSNotificationCenter defaultCenter]postNotificationName:LOGIN_ACCOUT_NOTI object:nil];
    } failure:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}



@end
