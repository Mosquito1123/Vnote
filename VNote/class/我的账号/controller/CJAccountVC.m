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
@property (weak, nonatomic) IBOutlet UILabel *noteOrderL;

@end

@implementation CJAccountVC
- (IBAction)avtarClick:(UITapGestureRecognizer *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
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
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)shareSwitch:(UISwitch *)sender {
    CJUser *user = [CJUser sharedUser];
    BOOL is_share = user.is_share == 1;
    if (sender.isOn != is_share){
        // 说明状态不同
        NSString *is_share = sender.isOn ? @"1" : @"0";
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
        [manger POST:API_SHARE_NOTE parameters:@{@"email":user.email,@"is_share":is_share} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            user.is_share = [is_share intValue];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [hud cjHideProgressHUD];
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [hud cjShowError:@"加载失败!"];
            }];
        }];
        
        
    }
}

- (IBAction)logout:(id)sender {
    // 登出
    CJTabBarVC *tabVC = (CJTabBarVC *)self.tabBarController;
    [tabVC toRootViewController];
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:@"nickname"];
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
    if (user.avtar_url.length){
        self.avtarImg.yy_imageURL = IMG_URL(user.avtar_url);
    }else{
        self.avtarImg.image = [UIImage imageNamed:@"avtar.png"];
    }
    CJCornerRadius(self.avtarImg)=self.avtarImg.cj_height/2;
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    NSString *noteOrder = [userD valueForKey:@"note_order"];
    if ([noteOrder isEqualToString:@"0"]){
        self.noteOrderL.text = @"标题升序";
    }else{
        self.noteOrderL.text = @"标题降序";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadAccountInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAcountNoti:) name:CHANGE_ACCOUNT_NOTI object:nil];
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
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    manger.requestSerializer.timeoutInterval = 20;
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"multipart/form-data"]];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
    [manger POST:API_UPLOAD_AVTAR parameters:@{@"email":user.email,@"img_type":imgType} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        double scaleNum = (double)300*1024/data.length;
        NSData *data;
        if(scaleNum < 1){
            
            data = UIImageJPEGRepresentation(image, scaleNum);
        }else{
            
            data = UIImageJPEGRepresentation(image, 0.1);
            
        }
        
        [formData  appendPartWithFileData:data name:@"avtar" fileName:@"file_name" mimeType:@"image/jpg/png/jpeg"];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        if ([dict[@"status"] intValue] == 0){
            CJUser *user = [CJUser sharedUser];
            user.avtar_url = dict[@"avtar_url"];
            NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
            [userD setValue:dict[@"avtar_url"] forKey:@"avtar_url"];
            [userD synchronize];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud cjHideProgressHUD];
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud cjShowError:@"上传失败!"];
        }];
        
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if (section == 2){
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *up = [UIAlertAction actionWithTitle:@"标题升序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.noteOrderL.text = @"标题升序";
            NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
            [userD setValue:@"0" forKey:@"note_order"];
            [userD synchronize];
            
        }];
        UIAlertAction *down = [UIAlertAction actionWithTitle:@"标题降序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.noteOrderL.text = @"标题降序";
            NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
            [userD setValue:@"1" forKey:@"note_order"];
            [userD synchronize];

        }];
        [vc addAction:cancel];
        [vc addAction:up];
        [vc addAction:down];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:vc animated:YES completion:nil];
        }];
        
    }
}



@end
