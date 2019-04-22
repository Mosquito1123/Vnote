//
//  CJBindEmailVC.m
//  VNote
//
//  Created by ccj on 2019/4/22.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJBindEmailVC.h"

@interface CJBindEmailVC ()
@property (weak, nonatomic) IBOutlet UITextField *emailL;

@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeL;
@property (weak, nonatomic) IBOutlet UIButton *bindBtn;
@property (weak, nonatomic) IBOutlet UITextField *passwdL;
@end

@implementation CJBindEmailVC
- (IBAction)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CJCornerRadius(self.sendCodeBtn) = 5;
    CJCornerRadius(self.bindBtn) = 5;
    self.sendCodeBtn.enabled = NO;
    self.bindBtn.enabled = NO;
    [self.emailL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwdL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.codeL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
}
-(void)textChanged{
    self.sendCodeBtn.enabled = self.emailL.text.length && self.passwdL.text.length;
    self.bindBtn.enabled = self.sendCodeBtn.enabled && self.codeL.text.length;
}

- (IBAction)sendCode:(id)sender {
    
}
- (IBAction)bindClick:(id)sender {
    
}


@end
