//
//  CJSexVC.m
//  VNote
//
//  Created by ccj on 2018/8/27.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSexVC.h"

@interface CJSexVC ()

@end

@implementation CJSexVC
- (IBAction)changeSex:(UIButton *)sender {
    NSString *sex = sender.titleLabel.text;
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.competion) self.competion(sex);
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.competion) self.competion(nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.competion) self.competion(nil);
}

@end
