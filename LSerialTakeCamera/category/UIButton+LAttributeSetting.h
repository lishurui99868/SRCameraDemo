//
//  UIButton+LAttributeSetting.h
//  LCustomCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (LAttributeSetting)
/**
 *  设置normal状态下标题和字体颜色
 */
- (void)setNormalTitle:(NSString *)title andTitleColor:(UIColor *)color;
/**
 *  设置normal状态下标题颜色
 */
- (void)setNormalTitleColor:(UIColor *)color;
/**
 *  设置normal状态下image
 */
- (void)setNormalImage:(NSString *)imageName;
/**
 *  设置高亮状态下image
 */
- (void)setHighLightImage:(NSString *)imageName;
/**
 *  设置normal状态下backgroundImage
 */
- (void)setNormalBackgroundImage:(NSString *)imageName;
/**
 *  设置选中状态下image
 */
- (void)setSelectedImage:(NSString *)imageName;
/**
 *  设置圆角
 */
- (void)setCornerWithFloat:(CGFloat)f;

@end
