用法：
CJSlideViewController *slideVc = [CJSlideViewController cjAddToViewControll:self withViewAddTo:self.view withViewFrame:CGRectMake(0, 100, CJScreenWidth, CJScreenHeight) withSubviewControllers:@[vc1,vc2,vc3,vc4,vc5,vc6,vc7] withSelectBlock:^(NSUInteger selectIndex, UIViewController *selectVC) {
NSLog(@"selectIndex=%ld",selectIndex);
NSLog(@"%@",selectVC.title);
}];
slideVc.cjLineViewColor=[UIColor blueColor];


需要依赖的接口
CJViewExtension
