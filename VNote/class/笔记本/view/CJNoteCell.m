//
//  CJNoteCell.m
//  VNote
//
//  Created by ccj on 2019/3/19.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJNoteCell.h"

@interface CJNoteCell ()
@property (weak, nonatomic) IBOutlet UIImageView *tagImg;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeL;

@property (weak, nonatomic) IBOutlet UILabel *tagL;
@end
@implementation CJNoteCell
+(CGFloat)height{
    return 70.f;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(instancetype)xibWithNoteCell{
    CJNoteCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"CJNoteCell" owner:nil options:nil]lastObject];
    return cell;
}
-(void)setUI:(CJNote *)n{
    self.titleL.text = n.title;
    self.updateTimeL.text = [NSDate cjDateSince1970WithSecs:n.updated_at formatter:@"YYYY/MM/dd"];
    self.updateTimeL.textColor = [UIColor grayColor];
    NSString *subStr = [n.tags substringWithRange:NSMakeRange(1, n.tags.length-2)];
    if ([subStr isEqualToString:@""]){
        self.tagImg.hidden = YES;
    }else{
        self.tagImg.hidden = NO;
        subStr = [subStr stringByReplacingOccurrencesOfString:@" " withString:@""];

        NSString *tmp1 = [subStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        NSString *tmp2 = [tmp1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString *tmp3 = [[@"\"" stringByAppendingString:tmp2] stringByAppendingString:@"\""];
        NSData *data = [tmp3 dataUsingEncoding:NSUTF8StringEncoding];
        NSString *res = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
        res = [res stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
        res = [res stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        self.tagL.text = res;
        self.tagL.textColor = [UIColor grayColor];

    }
    
}



@end
