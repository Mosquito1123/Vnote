//
//  AppDelegate.m
//  VNote
//
//  Created by ccj on 2018/5/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "AppDelegate.h"
#import "CJMainNaVC.h"
#import "CJMainVC.h"
#import "CJLoginVC.h"

@interface AppDelegate ()

typedef NS_ENUM(NSInteger,CJAuthenType){
    CJAuthenTypeSuccess,
    CJAuthenTypeWrongAccountOrPasswd,
    CJAuthenTypeWrongNet,
    CJAuthenTypeUnkonw
};
@property (nonatomic,assign) CJAuthenType authenType;
@end

@implementation AppDelegate

-(void)loginRequest{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    CJUser *user = [CJUser userWithUserDefaults:userD];
    NSString *email = user.email;
    NSString *passwd = user.password;
    if(email == nil || passwd == nil){
        self.authenType = CJAuthenTypeUnkonw;
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_LOGIN]];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 5;
        NSString *e = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)email, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
        NSString *p = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)passwd, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
        
        NSString *body = [NSString stringWithFormat:@"email=%@&passwd=%@",e,p];
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
        CJLog(@"%@",body);
        NSURLSession *session = [NSURLSession sharedSession];
        
        CJWeak(self)
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error){
                weakself.authenType = CJAuthenTypeWrongNet;
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([dic[@"status"] intValue] == 0){
                [CJUser userWithDict:dic];
                [CJTool catchAccountInfo2Preference:dic];
                weakself.authenType = CJAuthenTypeSuccess;
            }
            else{
                weakself.authenType = CJAuthenTypeWrongAccountOrPasswd;
            }
            dispatch_semaphore_signal(semaphore);   //发送信号
        }];
        [task resume];
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    }

}


-(void)rotateChange{

    [[NSNotificationCenter defaultCenter] postNotificationName:ROTATE_NOTI object:nil];

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    _authenType = CJAuthenTypeUnkonw;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    [self loginRequest];
    if (self.authenType == CJAuthenTypeSuccess){
        
        UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:vc];
        self.window.rootViewController = leftVC;
        
    }else{
        CJLoginVC *vc = [[CJLoginVC alloc]init];
        self.window.rootViewController = vc;
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
