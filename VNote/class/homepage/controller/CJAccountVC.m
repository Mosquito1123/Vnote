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
@interface CJAccountVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *avtarImg;
@property (weak, nonatomic) IBOutlet UISwitch *isShare;

@end

@implementation CJAccountVC
- (IBAction)avtarClick:(UITapGestureRecognizer *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
        [manger POST:API_SHARE_NOTE parameters:@{@"email":user.email,@"is_share":is_share} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            user.is_share = [is_share intValue];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
        
    }
}

- (IBAction)logout:(id)sender {
    // 登出
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:@"nickname"];
    [userD removeObjectForKey:@"password"];
    [userD synchronize];
    
    AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    d.window.rootViewController = [[CJLoginVC alloc]init];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 选取完图片后跳转回原控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    /* 此处参数 info 是一个字典，下面是字典中的键值 （从相机获取的图片和相册获取的图片时，两者的info值不尽相同）
     * UIImagePickerControllerMediaType; // 媒体类型
     * UIImagePickerControllerOriginalImage; // 原始图片
     * UIImagePickerControllerEditedImage; // 裁剪后图片
     * UIImagePickerControllerCropRect; // 图片裁剪区域（CGRect）
     * UIImagePickerControllerMediaURL; // 媒体的URL
     * UIImagePickerControllerReferenceURL // 原件的URL
     * UIImagePickerControllerMediaMetadata // 当数据来源是相机时，此值才有效
     */
    // 从info中将图片取出，并加载到imageView当中
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
//    NSData *data =UIImageJPEGRepresentation(image,1.0);
//    CJUser *user = [CJUser sharedUser];
//    NSString *imgType = [self typeForImageData:data];
//    NSString *pictureDataString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    [CJFetchData fetchDataWithAPI:API_UPLOAD_AVTAR postData:@{@"email":user.email,@"avtar":pictureDataString,@"img_type":imgType} completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        if ([dict[@"status"] intValue] == 0){
//            CJUser *user = [CJUser sharedUser];
//            user.avtar_url = dict[@"avtar_url"];
//            NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
//            [userD setValue:dict[@"avtar_url"] forKey:@"avtar_url"];
//            [userD synchronize];
//        }
//    }];
    
    
}



@end
