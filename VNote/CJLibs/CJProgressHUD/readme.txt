用法：
1>显示普通加载（菊花加载）
CJProgressHUD *hud=[CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:6 withText:@"加载中" withImages:nil];
2>显示动画记载（动画由多个图片构成）
CJProgressHUD *hud=[CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:6 withText:nil withImages:images];//images承载UIImage对象

3>隐藏加载动画
[hud cjHideProgressHUD];

4>加载成功
[hud cjShowSuccess:@"加载成功"]

5>加载失败
[hud cjShowError:@"加载失败"]

注意点：
1>强弱引用
__block __weak typeof(hud) weakHud=hud;
