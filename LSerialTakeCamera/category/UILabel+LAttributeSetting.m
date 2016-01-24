//
//  UILabel+LAttributeSetting.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 20/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "UILabel+LAttributeSetting.h"

@implementation UILabel (LAttributeSetting)

// 设置属性
- (void)setLabelTextColor:(UIColor *)c andFont:(CGFloat)f andText:(NSString *)t andAlignment:(NSTextAlignment)a {
    self.textColor = c;
    self.font = [UIFont systemFontOfSize:f];
    self.textAlignment = a;
    self.text = t;
    self.numberOfLines = 0;
}

@end
