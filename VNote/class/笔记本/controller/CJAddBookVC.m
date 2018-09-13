//
//  CJAddBookVC.m
//  VNote
//
//  Created by ccj on 2018/7/21.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAddBookVC.h"

@interface CJAddBookVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet UITextField *bookTextF;

@end

@implementation CJAddBookVC
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc{
  
}
- (IBAction)done:(id)sender {
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:0 withText:@"加载中..." withImages:nil];
    CJWeak(self)
    [CJAPI addBookWithParams:@{@"email":user.email,@"book_name":self.bookTextF.text} success:^(NSDictionary *dic) {
        [CJRlm addObject:[CJBook bookWithDict:@{@"name":dic[@"name"],@"count":@"0",@"uuid":dic[@"uuid"]}]];
        [hud cjShowSuccess:@"创建成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(NSError *error) {
        
    }];
    
    
}

-(void)textChange{
    self.doneBtn.enabled = self.bookTextF.text.length;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.doneBtn.enabled = NO;
    [self.bookTextF becomeFirstResponder];
    [self.bookTextF addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    
}


@end
