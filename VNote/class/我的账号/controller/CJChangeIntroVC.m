//
//  CJChangeIntroVC.m
//  VNote
//
//  Created by ccj on 2018/8/27.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJChangeIntroVC.h"

@interface CJChangeIntroVC ()
@property (weak, nonatomic) IBOutlet CJTextView *introView;

@end

@implementation CJChangeIntroVC
-(void)textChange{
    NSString *text = self.introView.text;
    CJUser *user = [CJUser sharedUser];
    self.navigationItem.rightBarButtonItem.enabled = text.length;
    if ([text isEqualToString:user.introduction]){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"简介";
    [self.introView becomeFirstResponder];
    NSString *t = [CJUser sharedUser].introduction;
    if ([t isEqualToString:@"无简介"]){
        self.introView.placeholder = @"我的WeNote简介";
    }else{
        self.introView.text = t;
    }
    
    self.introView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.introView.layer.borderWidth = 1.0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
    
}
-(void)done{
    [self.view endEditing:YES];
    NSString *text = self.introView.text;
    CJUser *user = [CJUser sharedUser];
    if ([text isEqualToString:user.introduction]){
        return;
    }
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"更改中..." withImages:nil];
    // 在发送前检查字符的长度
    if (self.introView.text.length >=30){
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionNavigationBar withText:@"字数过大!"];
        return;
    }
    [CJAPI requestWithAPI:API_CHANGE_INTRODUCTION params:@{@"email":user.email,@"introduction":text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"更改成功"];
        user.introduction = text;
        [CJTool catchAccountInfo2Preference:[user toDic]];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
}



@end
