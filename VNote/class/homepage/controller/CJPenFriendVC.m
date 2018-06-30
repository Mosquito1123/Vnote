//
//  CJPenFriendVC.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFriendVC.h"
#import "CJPenFriendCell.h"
#import "CJPenFriend.h"
@interface CJPenFriendVC ()
@property(nonatomic,strong)NSMutableArray *penFrinedArrM;
@end

@implementation CJPenFriendVC

-(NSMutableArray *)penFrinedArrM{
    if (!_penFrinedArrM){
        _penFrinedArrM = [NSMutableArray array];
    }
    return _penFrinedArrM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"penFriendCell"];
    
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    CJUser *user = [CJUser sharedUser];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [CJFetchData fetchDataWithAPI:API_PEN_FRIENDS postData:@{@"email":user.email} completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self.penFrinedArrM removeAllObjects];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",dic);
            if ([dic[@"status"] intValue] == 0){
                for (NSDictionary *d in dic[@"pen_friends"]) {
                    CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                    [self.penFrinedArrM addObject:pen];
                }
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.tableView.mj_header endRefreshing];
                    [self.tableView reloadData];
                }];
                
            }
        }];
    }];
    [self.tableView.mj_header beginRefreshing];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.penFrinedArrM.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"penFriendCell";
    CJPenFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [CJPenFriendCell xibPenFriendCell];
    }
    CJPenFriend *penf = self.penFrinedArrM[indexPath.row];
    if (penf.avtar_url.length){
        cell.avtar.yy_imageURL = IMG_URL(penf.avtar_url);
    }else{
    
        cell.avtar.image = [UIImage imageNamed:@"avtar.png"];
    }
    cell.nicknameL.text = penf.nickname;
    cell.emailL.text = penf.email;
    NSLog(@"%@",penf.nickname);
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
