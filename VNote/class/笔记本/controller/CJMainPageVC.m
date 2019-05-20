//
//  CJMainPageVC.m
//  VNote
//
//  Created by ccj on 2019/5/2.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJMainPageVC.h"
#import "CJMainVC.h"
#import "CJTagVC.h"
#import "CJRightDropMenuVC.h"
#import "CJSearchUserVC.h"
#import "CJRenameBookView.h"
@interface CJMainPageVC ()<UIScrollViewDelegate,UIPopoverPresentationControllerDelegate>

@end

@implementation CJMainPageVC

-(void)addNote{
    
    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *res = [CJBook cjAllObjectsInRlm:rlm];
    if (!res.count){
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"你未创建笔记本!"];
        return;
    }
    CJLeftSliderVC *sliderVC = (CJLeftSliderVC *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [sliderVC showLeftViewAnimation];
}
-(void)addFriend{
    CJUser *user = [CJUser sharedUser];
    if (user.is_tourist){
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"请注册!"];
        return;
    }
    CJSearchUserVC *vc = [[CJSearchUserVC alloc]init];
    CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}


-(void)addBook{
    CJRenameBookView *view = [CJRenameBookView xibWithView];
    view.title = @"";
    CJWeak(self)
    [view showInView:self.tabBarController.view title:@"创建笔记本" confirm:^(NSString * text) {
        CJUser *user = [CJUser sharedUser];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.tabBarController.view timeOut:TIME_OUT withText:@"正在创建..." withImages:nil];
        
        [CJAPI requestWithAPI:API_ADD_BOOK params:@{@"email":user.email,@"book_name":text} success:^(NSDictionary *dic) {
            [CJRlm addObject:[CJBook bookWithDict:@{@"name":dic[@"name"],@"count":@"0",@"uuid":dic[@"uuid"]}]];
            [hud cjShowSuccess:@"创建成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [view hide];
            });
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
    }];

}
- (IBAction)add:(id)sender {
    CJWeak(self)
    CJRightDropMenuVC *vc = [CJRightDropMenuVC dropMenuWithImages:@[@"加笔记本蓝",@"加笔记蓝"] titles:@[@"+笔记本",@"+笔记"] itemHeight:40.f width:140.f didclick:^(NSInteger index) {
        if (index == 0){
            [weakself addBook];
        }else if (index == 1){
            [weakself addNote];
        }
    }];

    UIPopoverPresentationController *popController = vc.popoverPresentationController;
    popController.backgroundColor = [UIColor whiteColor];
    popController.delegate = self;
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAvtar];
    // Do any additional setup after loading the view.
    CJMainVC *bookvc = [[CJMainVC alloc]init];
    CJTagVC *tagvc = [[CJTagVC alloc]init];
    [self cjNavigationSliderControllerWithTitles:@[@"笔记本",@"标签"] titleSelectColor:[UIColor whiteColor] normalColor:[UIColor lightGrayColor] subviewControllers:@[bookvc,tagvc] didClickItem:^(NSInteger buttonIndex) {
        
    }];
    
}



@end
