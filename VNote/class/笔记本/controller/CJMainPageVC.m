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
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addBookNav"];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];

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
