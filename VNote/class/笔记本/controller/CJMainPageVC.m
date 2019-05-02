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
- (IBAction)sort:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *up = [UIAlertAction actionWithTitle:@"标题 ↑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CJTool saveUserInfo2JsonWithNoteOrder:NoteOrderTypeUp closePenfriendFunc:[CJTool getClosePenFriendFunc]];
    }];
    UIAlertAction *down = [UIAlertAction actionWithTitle:@"标题 ↓" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CJTool saveUserInfo2JsonWithNoteOrder:NoteOrderTypeDown closePenfriendFunc:[CJTool getClosePenFriendFunc]];
    }];
    [vc addAction:cancel];
    [vc addAction:up];
    [vc addAction:down];
    UIPopoverPresentationController *popover = vc.popoverPresentationController;
    
    if (popover) {
        popover.barButtonItem = sender;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController:vc animated:YES completion:nil];
    
}

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
    
    CJRightDropMenuVC *vc = [[CJRightDropMenuVC alloc]init];
    vc.didSelectIndex = ^(NSInteger index){
        if (index == 0){
            [self addBook];
        }else if (index == 1){
            [self addNote];
        }else if (index == 2){
            [self addFriend];
        }
    };
    CGFloat menuH = 3 * 40.0 + 20.0;
    vc.preferredContentSize = CGSizeMake(160, menuH);
    vc.modalPresentationStyle = UIModalPresentationPopover;
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
