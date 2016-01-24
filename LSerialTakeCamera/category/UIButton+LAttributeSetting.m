//
//  UIButton+LAttributeSetting.m
//  LCustomCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "UIButton+LAttributeSetting.h"

@implementation UIButton (LAttributeSetting)
/**
 *  设置normal状态下标题和字体颜色
 */
- (void)setNormalTitle:(NSString *)title andTitleColor:(UIColor *)color {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateNormal];
}
/**
 *  设置normal状态下image
 */
- (void)setNormalImage:(NSString *)imageName {
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}
/**
 *  设置高亮状态下image
 */
- (void)setHighLightImage:(NSString *)imageName {
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}
/**
 *  设置normal状态下backgroundImage
 */
- (void)setNormalBackgroundImage:(NSString *)imageName {
    [self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}
/**
 *  设置选中状态下image
 */
- (void)setSelectedImage:(NSString *)imageName {
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
}
/**
 *  设置圆角
 */
- (void)setCornerWithFloat:(CGFloat)f {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = f;
}


@end
