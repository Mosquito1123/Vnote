//
//  CJLaunchScreenVC.h
//  VNote
//
//  Created by ccj on 2018/7/8.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJLaunchScreenVC : UIViewController

typedef NS_ENUM(NSInteger,CJAuthenType){
    CJAuthenTypeSuccess,
    CJAuthenTypeWrongAccountOrPasswd,
    CJAuthenTypeWrongNet,
    CJAuthenTypeUnkonw
};

@end
