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
- (IBAction)done:(id)sender {
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    [manger POST:API_ADD_BOOK parameters:@{@"email":user.email,@"book_name":self.bookTextF.text}  progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud cjShowSuccess:@"创建成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"创建失败!"];
    }];
    
}

-(void)textChange{
    self.doneBtn.enabled = self.bookTextF.text.length;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.doneBtn.enabled = NO;
    // Do any additional setup after loading the view.
    [self.bookTextF becomeFirstResponder];
    [self.bookTextF addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    
}


@end
