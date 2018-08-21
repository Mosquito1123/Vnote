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
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
        CJWeak(self)
        [CJAPI renameBookWithParams:@{@"book_uuid":self.book.uuid,@"book_title":text} success:^(NSDictionary *dic) {
            [[CJRlm shareRlm] transactionWithBlock:^{
                weakself.book.name = text;
            }];
            [hud cjShowSuccess:@"命名成功"];
            [weakself dismissViewControllerAnimated:YES completion:nil];
        
        } failure:^(NSError *error) {
            [hud cjShowError:@"命名失败!"];
        }];
        
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
- (IBAction)deleteBook:(id)sender {
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"删除中..." withImages:nil];
    CJWeak(self)
    [CJAPI deleteBookWithParams:@{@"email":user.email,@"book_uuid":self.book.uuid} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"删除成功"];
        [CJRlm deleteObject:weakself.book];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [hud cjShowError:@"操作失败!"];
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
