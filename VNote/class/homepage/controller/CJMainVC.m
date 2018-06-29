//
//  CJMainVC.m
//  VNote
//
//  Created by ccj on 2018/6/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJMainVC.h"
#import "CJConfig.h"
#import "CJNoteVC.h"
#import "CJBook.h"
#import "CJTag.h"
#import "CJAccountVC.h"
#import "CJLoginVC.h"
#import "CJTagVC.h"
#import "CJAccountVC.h"
@interface CJMainVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) NSMutableArray *booksArrM;
@property(strong,nonatomic) NSMutableArray *tagsArrM;
@property(strong,nonatomic) CJBook *allBook;
@property(strong,nonatomic) CJBook *recentBoook;
@property(strong,nonatomic) CJBook *inboxBook;
@property(strong,nonatomic) CJBook *trashBook;
@property(assign,nonatomic) NSInteger selectIndex;
@property(strong,nonatomic) IBOutlet UITableView *bookView;
@property(strong,nonatomic) IBOutlet UITableView *tagView;
@end


@implementation CJMainVC

-(NSMutableArray *)booksArrM{
    if (!_booksArrM){
        _booksArrM = [[NSMutableArray alloc]init];
    }
    return _booksArrM;
}
-(NSMutableArray *)tagsArrM{
    if (!_tagsArrM){
        _tagsArrM = [[NSMutableArray alloc]init];
    }
    return _tagsArrM;
}
-(void)segmentAction:(UISegmentedControl *)control{
    self.selectIndex = control.selectedSegmentIndex;
    if (self.selectIndex == 0){
        [self.bookView reloadData];
        [self.view bringSubviewToFront:self.bookView];
        if(!self.booksArrM.count){
            [self.bookView.mj_header beginRefreshing];
        }
        
    }
    else if (self.selectIndex == 1){
        [self.tagView reloadData];
        [self.view bringSubviewToFront:self.tagView];
        if(!self.tagsArrM.count){
            [self.tagView.mj_header beginRefreshing];
        }
    }

    
}


-(void)loadBookViewData{
    
    self.bookView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        NSString *nickname = [userD valueForKey:@"nickname"];
        if (!nickname){
            return ;
        }
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_GET_ALL_BOOKS]];
        request.HTTPMethod = @"POST";
        NSDictionary *parms = @{@"nickname":nickname};
        NSData *data = [NSJSONSerialization dataWithJSONObject:parms options:NSJSONWritingPrettyPrinted error:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = data;
        // 加载数据
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self.booksArrM removeAllObjects];
            // 解析data数据信息
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            for (NSDictionary *d in dic[@"res"][@"book_info_list"]){
                CJBook *book = [CJBook bookWithDict:d];
                [self.booksArrM addObject:book];
            }
            self.trashBook = [CJBook bookWithDict:dic[@"res"][@"trash_book"]];
            self.allBook = [CJBook bookWithDict:dic[@"res"][@"all_book"]];
            self.recentBoook = [CJBook bookWithDict:dic[@"res"][@"recent_book"]];
            self.inboxBook = [CJBook bookWithDict:dic[@"res"][@"inbox_book"]];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.bookView.mj_header endRefreshing];
                [self.bookView reloadData];
            });

        }];
        [task resume];
    }];
    
}

-(void)loadTagViewData{
    self.tagView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        NSString *nickname = [userD valueForKey:@"nickname"];
        if (!nickname){
            return ;
        }
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_GET_ALL_TAGS]];
        request.HTTPMethod = @"POST";
        NSDictionary *parms = @{@"nickname":nickname};
        NSData *data = [NSJSONSerialization dataWithJSONObject:parms options:NSJSONWritingPrettyPrinted error:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = data;
        // 加载数据
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self.tagsArrM removeAllObjects];
            // 解析data数据信息
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            for (NSDictionary *d in dic[@"res"]){
                CJTag *tag = [CJTag tagWithDict:d];
                [self.tagsArrM addObject:tag];
            }

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tagView.mj_header endRefreshing];
                [self.tagView reloadData];
            });

        }];
        [task resume];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UISegmentedControl *titleView = [[UISegmentedControl alloc]initWithItems:@[@"笔记本",@"标签"]];
//    titleView.tintColor = [UIColor whiteColor];
    titleView.selectedSegmentIndex = 0;
    [titleView addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = titleView;
    

    self.tagView.backgroundColor = MainBg;
    self.tagView.tableFooterView = [[UIView alloc]init];
    

    self.bookView.backgroundColor = MainBg;
    self.bookView.tableFooterView = [[UIView alloc]init];
    // 判断是否在登录状态,获取账号和密码去验证？？？？
    
    [self loadTagViewData];
    [self loadBookViewData];
    [self.bookView.mj_header beginRefreshing];
    
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID1 = @"cell1",*cellID2 = @"cell2";
    NSInteger section = indexPath.section;
    UITableViewCell *cell;
    if (section == 0 || section == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID1];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = MainBg;
        cell.textLabel.textColor = HeadFontColor;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    }else if (section == 1 || section == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:cellID2];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID2];
        }
        
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        if (section == 3){
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            UIImage *img = [UIImage imageNamed:@"download.png"];
//            [button setImage:img forState:UIControlStateNormal];
//            button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
//            cell.accessoryView = button;
//            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
        }
        
    }
    
    
    NSString *text;
    
    if (self.selectIndex == 1){
        if (section == 0){
            text = @"Tags";
        }else{
            CJTag *tag = self.tagsArrM[indexPath.row];
            text =tag.tag;
        }
        
    }
    else{
        if (section == 0){
            text = @"LIBRARY";
            
        }else if(section == 1){
            switch (indexPath.row) {
                case 0:
                    text = @"Recents";
                    break;
                case 1:
                    text = @"Trash";
                    break;
                case 2:
                    text = @"All Notes";
                    break;
                default:
                    break;
            }
            
        }else if (section == 2){
            text = @"NOTEBOOKS";
            
        
        }else if (section == 3){
            CJBook *book = self.booksArrM[indexPath.row];
            text = book.name;
            
        }
    }
    cell.textLabel.text = text;

    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.selectIndex == 1){
        //tags
        return 2;
    }
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.selectIndex == 1){
        if (section == 0){
            return 1;
        }
        else{
            return self.tagsArrM.count;
        }
    }
    
    if (section == 0){
        return 1;
    }
    else if(section == 1){
        return 3;
    }else if (section == 2){
        return 1;
    }else if(section == 3){
        return self.booksArrM.count;
    }
    return 0;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"bxjabsja");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryView){
        return;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (self.selectIndex == 0){
        // 点击bookView里面的cell
        NSString *title,*uuid;
        if (section == 0 || section == 2){
            return;
        }
        if (section == 1){
            switch (row) {
                case 0:
                    //Recents
                    title = @"Recents";
                    uuid = self.recentBoook.uuid;
                    break;
                case 1:
                    //Trash
                    title = @"Trash";
                    uuid = self.trashBook.uuid;
                    break;
                case 2:
                    //All Notes
                    title = @"All Notes";
                    uuid = self.allBook.uuid;
                    break;
                default:
                    break;
            }
        }
        else if (section == 3){
            CJBook *book = self.booksArrM[row];
            title = book.name;
            uuid = book.uuid;
        }
        CJNoteVC *noteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
        noteVC.book_uuid = uuid;
        noteVC.book_title = title;
        [self.navigationController pushViewController:noteVC animated:YES];
    }else if (self.selectIndex == 1){
        // 点击tags里面的cell
        if (section == 1){
            // 显示当前下面tag下面的笔记数目
            CJTag *tag = self.tagsArrM[row];
            CJTagVC *tagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tagVC"];
            tagVC.tagTitle = tag.tag;
            tagVC.noteInfos = tag.noteInfos;
            [self.navigationController pushViewController:tagVC animated:YES];
        }
        
    }
    
    
    
}




@end
