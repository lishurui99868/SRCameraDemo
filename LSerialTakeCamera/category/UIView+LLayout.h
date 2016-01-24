//
//  UIView+LLayout.h
//  LCustomCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LLayout)

- (CGFloat)maxX;
- (CGFloat)maxY;
- (CGFloat)minX;
- (CGFloat)minY;
- (CGFloat)midX;
- (CGFloat)midY;

- (CGFloat)X;
- (CGFloat)Y;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

- (CGFloat)height;
- (CGFloat)width;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

- (void)setFrameCenterWithSuperView:(UIView *)superView size:(CGSize)size;
- (void)setFrameInBottomCenterWithSuperView:(UIView *)superView size:(CGSize)size;

- (void)addCorner;

@end
