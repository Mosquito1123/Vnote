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
        [CJFetchData fetchDataWithAPI:API_RENAME_BOOK postData:@{@"book_uuid":self.book_uuid,@"book_title":text} completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
- (IBAction)deleteBook:(id)sender {
    CJUser *user = [CJUser sharedUser];
    [CJFetchData fetchDataWithAPI:API_DEL_BOOK postData:@{@"email":user.email,@"book_uuid":self.book_uuid} completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

       [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
