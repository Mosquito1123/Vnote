//
//  CJNotebookVC.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNoteVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
@interface CJNoteVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *noteArrM;
@end

@implementation CJNoteVC
-(NSMutableArray *)noteArrM{
    if(!_noteArrM){
        _noteArrM = [NSMutableArray array];
    }
    return _noteArrM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.book_title;
    // Do any additional setup after loading the view.
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSLog(@"llll");
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        NSString *nickname = [userD valueForKey:@"nickname"];
        if (!nickname){
            return ;
        }
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_BOOK_DETAIL]];
        request.HTTPMethod = @"POST";
        NSDictionary *parms = @{@"nickname":nickname,@"book_uuid":self.book_uuid};
        NSData *data = [NSJSONSerialization dataWithJSONObject:parms options:NSJSONWritingPrettyPrinted error:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = data;
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self.noteArrM removeAllObjects];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *res = dic[@"res"];
            for (NSDictionary *dic in res){
                CJNote *note = [CJNote noteWithDict:dic];
                [self.noteArrM addObject:note];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView reloadData];
            });
        }];
        [task resume];
        
    }];
    
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [[UIView alloc]init];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.noteArrM[row];
    cell.textLabel.text = note.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.noteArrM.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[CJContentVC alloc]init];
    CJNote *note = self.noteArrM[indexPath.row];
    contentVC.uuid = note.uuid;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
