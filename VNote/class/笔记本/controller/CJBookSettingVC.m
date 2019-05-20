//
//  CJBookSettingVC.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBookSettingVC.h"
#import "CJBook.h"
@interface CJBookSettingVC ()
@property (weak, nonatomic) IBOutlet UITextField *bookTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setDoneBtn;

@end

@implementation CJBookSettingVC
- (IBAction)setingDone:(id)sender {
    NSString *text = self.bookTextField.text;
    if (![text isEqualToString:self.book.name]){
        // 有改动
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
        CJWeak(self)
        [CJAPI requestWithAPI:API_RENAME_BOOK params:@{@"book_uuid":weakself.book.uuid,@"book_title":text} success:^(NSDictionary *dic) {
            [[CJRlm shareRlm] transactionWithBlock:^{
                weakself.book.name = text;
            }];
            [hud cjShowSuccess:@"命名成功"];
            [weakself dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
- (IBAction)deleteBook:(id)sender {
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];
    CJWeak(self)
    [CJAPI requestWithAPI:API_DEL_BOOK params:@{@"email":user.email,@"book_uuid":weakself.book.uuid} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"删除成功"];
        [CJRlm deleteObject:weakself.book];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookTextField.text = self.book.name;
    [self.bookTextField addTarget:self action:@selector(bookTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)bookTextFieldChange:(UITextField *)textF{
    self.setDoneBtn.enabled = textF.text.length;
}



@end
