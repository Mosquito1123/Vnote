//
//  CJRightDropMenuVC.m
//  VNote
//
//  Created by ccj on 2019/4/16.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJRightDropMenuVC.h"

@interface CJRightDropMenuVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,copy) DidSelectIndex didclick;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray <NSString *>*images;
@property (nonatomic,strong) NSArray <NSString *>*titles;
@end

@implementation CJRightDropMenuVC

-(void)viewDidLoad{
    self.tableView.bounces = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSInteger row = indexPath.row;
    if (self.images){
        NSString *imageName = self.images[row];
        if (imageName.length){
            cell.imageView.image = [UIImage imageNamed:imageName];
        }
        
    }
    NSString *text = self.titles[row];
    cell.textLabel.text = text;
    cell.textLabel.textColor = BlueBg;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.didclick){
        self.didclick(indexPath.row);
    }
}

+(instancetype)dropMenuWithImages:(NSArray<NSString *> *)images titles:(NSArray<NSString *> *)titles itemHeight:(CGFloat)height width:(CGFloat)width didclick:(DidSelectIndex)click{
    CJRightDropMenuVC *vc = [[CJRightDropMenuVC alloc]init];
    vc.tableView.bounces = NO;
    vc.tableView.rowHeight = height;
    vc.preferredContentSize = CGSizeMake(width, titles.count * height + 20.f);
    vc.didclick = click;
    vc.images = images;
    vc.titles = titles;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    return vc;
}


@end
