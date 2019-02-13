//
//  CJAccountVC.m
//  VNote
//
//  Created by ccj on 2018/6/10.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAccountVC.h"
#import "AppDelegate.h"
#import "CJLoginVC.h"
#import "CJTabBarVC.h"
@interface CJAccountVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *avtarImg;
@property (weak, nonatomic) IBOutlet UISwitch *isShare;
@property (weak, nonatomic) IBOutlet UILabel *sexL;
@property (weak, nonatomic) IBOutlet UILabel *joinedL;
@end

@implementation CJAccountVC

- (IBAction)avtarClick:(UITapGestureRecognizer *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"更换头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takeP = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        // 展示选取照片控制器
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *p = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [vc addAction:takeP];
    [vc addAction:p];
    [vc addAction:cancel];
    UIPopoverPresentationController *popover = vc.popoverPresentationController;
    
    if (popover) {
        popover.sourceView = sender.view;
        popover.sourceRect = sender.view.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)shareSwitch:(UISwitch *)sender {
    CJUser *user = [CJUser sharedUser];
    BOOL is_share = user.is_share == 1;
    if (sender.isOn != is_share){
        // 说明状态不同
        NSString *is_share = sender.isOn ? @"1" : @"0";
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
        [CJAPI shareNoteWithParams:@{@"email":user.email,@"is_share":is_share} success:^(NSDictionary *dic) {
            user.is_share = [is_share intValue];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [hud cjHideProgressHUD];
            }];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (IBAction)logout:(id)sender {
    // 登出
    CJTabBarVC *tabVC = (CJTabBarVC *)self.tabBarController;
    CJLeftXViewController *vc = (CJLeftXViewController *)[tabVC parentViewController];
    [vc toRootViewController];
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:@"email"];
    [userD removeObjectForKey:@"password"];
    [userD synchronize];

    
}

-(void)reloadAccountInfo{
    CJUser *user = [CJUser sharedUser];
    self.navigationItem.title = user.nickname;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = BlueBg;
    self.nicknameLabel.text = user.email;
    self.nicknameLabel.textColor = [UIColor whiteColor];
    self.headView.backgroundColor = BlueBg;
    self.avtarImg.backgroundColor = [UIColor whiteColor];
    self.isShare.on = user.is_share;
    [self.avtarImg yy_setImageWithURL:IMG_URL(user.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    CJCornerRadius(self.avtarImg)=self.avtarImg.cj_height/2;
    self.sexL.text = user.sex;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[user.date_joined integerValue]];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"yyyy年MM月"];
    NSString *str = [NSString stringWithFormat:@"从%@开始成为WeNote用户",[dateformatter stringFromDate:date]];
    self.joinedL.font = [UIFont italicSystemFontOfSize:13];
    self.joinedL.text = str;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadAccountInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAcountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        CJUser *user = [CJUser sharedUser];
        [CJAPI loginWithParams:@{@"email":user.email,@"passwd":user.password} success:^(NSDictionary *dic) {
            [weakself.tableView.mj_header endRefreshing];
            [weakself reloadAccountInfo];
        } failure:^(NSError *error) {
            [weakself.tableView.mj_header endRefreshing];
        }];
    }];
    
}

-(void)changeAcountNoti:(NSNotification *)noti{
    [self reloadAccountInfo];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 选取完图片后跳转回原控制器
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.avtarImg.image = image;
    
    [self uploadAvtar:image];
}

// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    
    return nil;
    
}

-(void)uploadAvtar:(UIImage *)image{
    NSData *data =UIImageJPEGRepresentation(image,1.0);
    CJUser *user = [CJUser sharedUser];
    NSString *imgType = [self typeForImageData:data];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    manger.requestSerializer.timeoutInterval = 20;
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"multipart/form-data"]];
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    [manger POST:API_UPLOAD_AVTAR parameters:@{@"email":user.email,@"img_type":imgType} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        double scaleNum = (double)300*1024/data.length;
        NSData *data;
        if(scaleNum < 1){
            data = UIImageJPEGRepresentation(image, scaleNum);
        }else{
            data = UIImageJPEGRepresentation(image, 0.1);
        }
        [formData appendPartWithFileData:data name:@"avtar" fileName:@"file_name" mimeType:@"image/jpg/png/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        if ([dict[@"status"] intValue] == 0){
            CJUser *user = [CJUser sharedUser];
            user.avtar_url = dict[@"avtar_url"];
           
            NSDictionary *dic =  [user toDic];
            
            [CJTool catchAccountInfo2Preference:dic];
            [hud cjShowSuccess:@"上传成功"];
            NSNotification *noti = [NSNotification notificationWithName:LOGIN_ACCOUT_NOTI object:nil];
            [[NSNotificationCenter defaultCenter]postNotification:noti];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [hud cjShowError:@"网络不在状态!"];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1){
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"修改性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        CJUser *user = [CJUser sharedUser];
        CJWeak(self)
        UIAlertAction *man = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([user.sex isEqualToString:@"男"]) return ;
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
            [CJAPI changeSexWithParams:@{@"email":user.email,@"sex":@"男"} success:^(NSDictionary *dic) {
                [hud cjShowSuccess:@"更改成功"];
                weakself.sexL.text = @"男";
                user.sex = @"男";
                [CJTool catchAccountInfo2Preference:[user toDic]];
            } failure:^(NSError *error) {
                
            }];
        }];
        UIAlertAction *woman = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([user.sex isEqualToString:@"女"]) return ;
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
            [CJAPI changeSexWithParams:@{@"email":user.email,@"sex":@"女"} success:^(NSDictionary *dic) {
                [hud cjShowSuccess:@"更改成功"];
                weakself.sexL.text = @"女";
                user.sex = @"女";
                [CJTool catchAccountInfo2Preference:[user toDic]];
            } failure:^(NSError *error) {
                
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [vc addAction:man];
        [vc addAction:woman];
        [vc addAction:cancel];
        UIPopoverPresentationController *popover = vc.popoverPresentationController;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (popover) {
            popover.sourceView = cell;
            popover.sourceRect = cell.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
