//
//  CJChangeIntroVC.m
//  VNote
//
//  Created by ccj on 2018/8/27.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJChangeIntroVC.h"

@interface CJChangeIntroVC ()
@property (weak, nonatomic) IBOutlet UITextView *introView;

@end

@implementation CJChangeIntroVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"简介";
    [self.introView becomeFirstResponder];
    self.introView.text = [CJUser sharedUser].introduction;
    self.introView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.introView.layer.borderWidth = 1.0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
}
-(void)done{
    [self.view endEditing:YES];
    NSString *text = self.introView.text;
    CJUser *user = [CJUser sharedUser];
    if ([text isEqualToString:user.introduction]){
        return;
    }
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"更改中..." withImages:nil];
    [CJAPI changeIntroWithParams:@{@"email":user.email,@"introduction":text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"更改成功"];
        user.introduction = text;
        [CJTool catchAccountInfo2Preference:[user toDic]];
    } failure:^(NSError *error) {
        [hud cjShowError:@"更改失败!"];
        
    }];
    
}



@end
