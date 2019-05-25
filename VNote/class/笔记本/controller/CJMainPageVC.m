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
