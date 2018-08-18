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
    if (![text isEqualToString:self.book_title]){
        // 有改动
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
        AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
        [manger POST:API_RENAME_BOOK parameters:@{@"book_uuid":self.book_uuid,@"book_title":text} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [hud cjHideProgressHUD];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"操作失败!"];
        }];
        
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
- (IBAction)deleteBook:(id)sender {
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_BOOK parameters:@{@"email":user.email,@"book_uuid":self.book_uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud cjHideProgressHUD];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"操作失败!"];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookTextField.text = self.book_title;
    [self.bookTextField addTarget:self action:@selector(bookTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)bookTextFieldChange:(UITextField *)textF{
    self.setDoneBtn.enabled = textF.text.length;
}



@end
