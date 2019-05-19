//
//  CJRenameBookView.m
//  VNote
//
//  Created by ccj on 2019/5/19.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJRenameBookView.h"
@interface CJRenameBookView()
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextField *titleT;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property(nonatomic,strong)UIView *coverView;
@end

@implementation CJRenameBookView

- (IBAction)cancelClick:(id)sender {
    [self hide];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    CJCornerRadius(self.cancelBtn) = 4;
    CJCornerRadius(self.okBtn) = 4;
    self.cancelBtn.layer.borderWidth = 0.5;
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.okBtn.layer.borderWidth = 0.5;
    self.okBtn.layer.borderColor = [UIColor whiteColor].CGColor;
}

+(instancetype)xibWithView{
    CJRenameBookView *view = [[[NSBundle mainBundle]loadNibNamed:@"CJRenameBookView" owner:nil options:nil]lastObject];
    CJCornerRadius(view) = 10;
    
    return view;
}


-(void)setTitle:(NSString *)title{
    self.titleT.text = title;
}

-(UIView *)coverView{
    if (!_coverView){
        _coverView = [[UIView alloc]init];
        _coverView .backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _coverView;
}
- (IBAction)doneClick:(id)sender {
    if (_click){
        
        self.click(self.titleT.text);
    }
}

-(void)showInView:(UIView *)view{
    CJWeak(self)
    self.alpha = 0.1;
    [UIView animateWithDuration:0.5 animations:^{
        weakself.alpha = 1.0;
    }];
    [view addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.with.height.equalTo(view);
    }];
    [self.coverView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300);
        make.center.equalTo(weakself.coverView);
    }];
    
}
-(void)hide{
    [self.coverView removeFromSuperview];
    [self removeFromSuperview];
    
}

@end
