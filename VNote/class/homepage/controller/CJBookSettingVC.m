//
//  CJBookSettingVC.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBookSettingVC.h"

@interface CJBookSettingVC ()
@property (weak, nonatomic) IBOutlet UITextField *bookTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setDoneBtn;

@end

@implementation CJBookSettingVC
- (IBAction)setingDone:(id)sender {
    NSString *text = self.bookTextField.text;
    if (text != self.book_title){
        // 有改动
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        [manger POST:API_RENAME_BOOK parameters:@{@"book_uuid":self.book_uuid,@"book_title":text} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
- (IBAction)deleteBook:(id)sender {
    CJUser *user = [CJUser sharedUser];
    
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    [manger POST:API_DEL_BOOK parameters:@{@"email":user.email,@"book_uuid":self.book_uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
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
