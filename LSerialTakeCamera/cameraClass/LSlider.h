//
//  LSlider.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 20/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>

/**slider的滑动方向*/
typedef NS_ENUM(NSInteger, LSliderDirection) {
    LSliderDirectionHorizonal = 0,
    LSliderDirectionVertical
};
/**改变value的值以后*/
typedef void(^LSliderDidChangeValueBlock)(CGFloat value);
/**点击结束*/
typedef void(^LSliderTouchEndBlock)(CGFloat value, BOOL isTouchEnd);

@interface LSlider : UIControl
/**最小值*/
@property (nonatomic, assign) CGFloat minValue;
/**最大值*/
@property (nonatomic, assign) CGFloat maxValue;
/**滑动值*/
@property (nonatomic, assign) CGFloat value;
/**是否让圆滑至两端后可以超出线半径个像素长*/
@property (nonatomic, assign) BOOL showHalfInEnd;
/**线的宽度*/
@property (nonatomic, assign) CGFloat lineWidth;
/**圆的半径*/
@property (nonatomic, assign) CGFloat circleRadius;
/**是否正在滑动*/
@property (nonatomic, assign) BOOL isSliding;

- (instancetype)initWithFrame:(CGRect)frame andDirection:(LSliderDirection)direction;
- (void)fillLineColor:(UIColor *)bgLineColor
      slidedLineColor:(UIColor *)slidedLineColor
          circleColor:(UIColor *)circleColor
       shouldShowHalf:(BOOL)showHalfInEnd
            lineWidth:(CGFloat)lineWidth
         circleRadius:(CGFloat)circleRadius;
- (void)didChangeValueBlock:(LSliderDidChangeValueBlock)block;
- (void)touchEndBlock:(LSliderTouchEndBlock)block;
/**
 *  设置value值，并设置是否要调用回调函数
 */
- (void)setValue:(CGFloat)value shouldCallBack:(BOOL)shouldCallBack;

@end
