用法：

直接调用类方法
CJDropView *dropView=[CJDropView cjShowDropVieWAnimationWithOption:CJDropViewAnimationTypeFlexible tranglePosition:CJTranglePositionRight cellModelArray:@[@"1",@"2",@"3",@"4",@"5"] detailAttributes:@{@"cjDropViewBgColor":[UIColor redColor]} cjDidSelectRowAtIndex:^(NSInteger index) {
NSLog(@"index=%ld",index);
}];


显示
[dropView cjShowDropView];

隐藏不需要调用

