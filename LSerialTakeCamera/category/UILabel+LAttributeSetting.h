//
//  UILabel+LAttributeSetting.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 20/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LAttributeSetting)

// 设置属性
- (void)setLabelTextColor:(UIColor *)c andFont:(CGFloat)f andText:(NSString *)t andAlignment:(NSTextAlignment)a;

@end
