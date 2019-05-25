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
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (nonatomic,copy) Click click;
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
    [self.titleT addTarget:self action:@selector(titleChange) forControlEvents:UIControlEventEditingChanged];
}

-(void)titleChange{
    self.okBtn.enabled = self.titleT.text.length;
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
        self.click(self.titleT.text,self);
    }
}

+(instancetype)showWithTitle:(NSString *)title bookname:(NSString *)name confirm:(Click)click{
    CJRenameBookView *view = [CJRenameBookView xibWithView];
    CJWeak(view)
    view.click = click;
    view.alpha = 0.1;
    view.titleT.text = name;
    [view titleChange];
    view.titleL.text = title;
    
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    CJWeak(w)
    [w addSubview:view.coverView];
    [view.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.with.height.equalTo(weakw);
    }];
    [view.coverView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300);
        make.centerX.equalTo(weakview.superview);
        make.centerY.equalTo(weakview.superview).offset(300.f);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakview.coverView);
        }];
        [UIView animateWithDuration:0.4 animations:^{
            weakview.alpha = 1.0;
            [weakview.superview layoutIfNeeded];
            
        }];
    });
    return view;
    
}
-(void)hide{
    [self.coverView removeFromSuperview];
    [self removeFromSuperview];
    
}

@end
