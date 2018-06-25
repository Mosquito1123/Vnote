//
//  UIViewController+guideView.h
//  尺寸的掌握
//
//  Created by ccj on 2016/12/21.
//  Copyright © 2016年 ccj. All rights reserved.
//



//使用说明：只要将当前的文件导入到项目当中，即可，在下面修改该宏即可

#import <UIKit/UIKit.h>

//修改imageName
#define ImageNameArrM @[@"欢迎页1",@"欢迎页2",@"欢迎页3"]
@interface UIViewController (guideView)<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>


@end
