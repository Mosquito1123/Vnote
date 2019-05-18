//
//  CJSearchVC.m
//  VNote
//
//  Created by ccj on 2019/5/2.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJSearchVC.h"
#import "CJSearchResVC.h"
@interface CJSearchVC ()<UISearchBarDelegate>
@property(strong,nonatomic) NSMutableArray *notes;
@end

@implementation CJSearchVC
-(NSMutableArray *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.hotSearches = nil;
    [self.searchBar setShowsCancelButton:NO animated:NO];
    self.searchBar.placeholder = @"输入笔记名、标签名称";
    self.searchHistoryStyle = PYSearchHistoryStyleNormalTag;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    CJWeak(self)
    self.didSearchBlock = ^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
            CJUser *user = [CJUser sharedUser];
            
            if (searchText.length == 0){
                return ;
            }
            [CJAPI requestWithAPI:API_SEARCH_NOTE params:@{@"email":user.email,@"key":searchText} success:^(NSDictionary *dic) {
                [weakself.notes removeAllObjects];
                for (NSDictionary *d in dic[@"key_notes"]) {
                    CJNote *note = [CJNote noteWithDict:d];
                    [weakself.notes addObject:note];
                }
                if (weakself.notes.count){
                    
                    [hud cjHideProgressHUD];
                    CJSearchResVC *vc = [[CJSearchResVC alloc]init];
                    vc.notes = weakself.notes;
                    [searchViewController.navigationController pushViewController:vc animated:YES];
                }else{
                    [hud cjShowError:@"无记录"];
                }
            } failure:^(NSDictionary *dic) {
                [hud cjShowError:@"无记录!"];
                
            } error:^(NSError *error) {
                [hud cjShowError:net101code];
            }];
        });
    };
}




@end
