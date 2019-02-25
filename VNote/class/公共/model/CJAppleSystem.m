//
//  CJAppleSystem.m
//  VNote
//
//  Created by ccj on 2019/2/25.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJAppleSystem.h"

@implementation CJAppleSystem
CJSingletonM(AppleSystem)
+ (UIImage *)launchImage {
    
    UIImage    *lauchImage  = nil;
    NSString    *viewOrientation = nil;
    CGSize     viewSize  = [UIScreen mainScreen].bounds.size;
    CGFloat viewH = viewSize.height;
    CGFloat viewW = viewSize.width;
    UIInterfaceOrientation orientation  = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        
        viewOrientation = @"Landscape";
        
    } else {
        
        viewOrientation = @"Portrait";
    }
    
    NSArray *imagesDictionary = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dict in imagesDictionary) {
        
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        CGFloat imgH = imageSize.height;
        CGFloat imgW = imageSize.width;
        
        if ((CGSizeEqualToSize(imageSize, CGSizeMake(viewSize.height, viewSize.width)) || CGSizeEqualToSize(imageSize, viewSize) ) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            
            lauchImage = [UIImage imageNamed:dict[@"UILaunchImageName"]];
        }
    }
    
    return lauchImage;
}
@end
