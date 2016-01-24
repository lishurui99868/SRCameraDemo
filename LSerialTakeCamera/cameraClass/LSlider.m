//
//  LSlider.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 20/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LSlider.h"

@interface LSlider (){
    CGFloat gap;
    CGFloat inverseGap;
}
/**方向*/
@property (nonatomic, assign) LSliderDirection direction;
/**整条线的颜色*/
@property (nonatomic, strong) UIColor * bgLineColor;
/**滑动过的线的颜色*/
@property (nonatomic, strong) UIColor * slidedLineColor;
/**圆的颜色*/
@property (nonatomic, strong) UIColor * circleColor;
/**滑动的比值*/
@property (nonatomic, assign) CGFloat scaleNum;
@property (nonatomic, copy) LSliderDidChangeValueBlock changeBlock;
@property (nonatomic, copy) LSliderTouchEndBlock touchBlock;

@end
@implementation LSlider

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andDirection:LSliderDirectionHorizonal];
}

- (instancetype)initWithFrame:(CGRect)frame andDirection:(LSliderDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.minValue = 0;
        self.maxValue = 1;
        _direction = direction;
        _bgLineColor = [UIColor whiteColor];
        _slidedLineColor = [UIColor whiteColor];
        _circleColor = [UIColor whiteColor];
        _showHalfInEnd = YES;
        _lineWidth = 1;
        _circleRadius = 10;
    }
    return self;
}

- (void)fillLineColor:(UIColor *)bgLineColor slidedLineColor:(UIColor *)slidedLineColor circleColor:(UIColor *)circleColor shouldShowHalf:(BOOL)showHalfInEnd lineWidth:(CGFloat)lineWidth circleRadius:(CGFloat)circleRadius {
    if (bgLineColor)
        _bgLineColor = bgLineColor;
    if (slidedLineColor)
        _slidedLineColor = slidedLineColor;
    if (circleColor)
        _circleColor = circleColor;
    _showHalfInEnd = showHalfInEnd;
    _lineWidth = lineWidth;
    _circleRadius = circleRadius;
    [self setNeedsDisplay];
}

- (void)setValue:(CGFloat)value {
    [self setValue:value shouldCallBack:YES];
}
/**
 *  设置value值，并设置是否要调用回调函数
 */
- (void)setValue:(CGFloat)value shouldCallBack:(BOOL)shouldCallBack {
    if (value != _value) {
        if (value < _minValue) {
            _value = _minValue;
            return;
        } else if (value > _maxValue) {
            _value = _maxValue;
            return;
        }
        _value = value;
        if (! shouldCallBack)
            _scaleNum = (_value - _minValue) / (_maxValue - _minValue);
        [self setNeedsDisplay];
        if (shouldCallBack) {
            if (_changeBlock)
                _changeBlock(value);
        }
    }
}

- (void)didChangeValueBlock:(LSliderDidChangeValueBlock)block {
    if (_changeBlock != block)
        _changeBlock = block;
}

- (void)touchEndBlock:(LSliderTouchEndBlock)block {
    if (_touchBlock != block)
        _touchBlock = block;
}

- (void)drawRect:(CGRect)rect {
    gap = (_showHalfInEnd ? _circleRadius : 0);
    inverseGap = (_showHalfInEnd ? 0 : _circleRadius);
    // 生成画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 画总体的线
    CGContextSetStrokeColorWithColor(context, _bgLineColor.CGColor); // 画笔颜色
    CGContextSetLineWidth(context, _lineWidth); // 线的宽度
    CGFloat startLineX = (_direction == LSliderDirectionHorizonal ? gap : (self.width - _lineWidth) / 2);
    CGFloat startLineY = (_direction == LSliderDirectionHorizonal ? (self.height - _lineWidth) / 2 : gap);
    CGFloat endLineX = (_direction == LSliderDirectionHorizonal ? self.width - gap : (self.width - _lineWidth) / 2);
    CGFloat endLineY = (_direction == LSliderDirectionHorizonal ? (self.height - _lineWidth) / 2 : self.height - gap);
    CGContextMoveToPoint(context, startLineX, startLineY); // 起点
    CGContextAddLineToPoint(context, endLineX, endLineY); // 终点
    CGContextClosePath(context);
    CGContextStrokePath(context);
    // 画已滑动进度的线
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, _lineWidth); // 线的宽度
    CGFloat slidedLineX = (_direction == LSliderDirectionHorizonal ? MAX(gap, (_scaleNum * self.width - gap)) : startLineX);
    CGFloat slidedLineY = (_direction == LSliderDirectionHorizonal ? startLineY : MAX(gap, (_scaleNum * self.height - gap)));
    CGContextMoveToPoint(context, startLineX, startLineY); // 起点
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY); // 终点
    CGContextClosePath(context);
    CGContextStrokePath(context);
    // 圆
    CGFloat penWidth = 1.f;
    CGFloat circleX = (_direction == LSliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth - inverseGap) : startLineX);
    CGFloat circleY = (_direction == LSliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth - inverseGap));
    CGContextSetStrokeColorWithColor(context, nil); // 画笔颜色
    CGContextSetLineWidth(context, 0); // 线的宽度
    CGContextSetFillColorWithColor(context, _circleColor.CGColor); // 填充颜色
    CGContextSetShadow(context, CGSizeMake(0, 0), 0.f); // 阴影
    CGContextAddArc(context, circleX, circleY, _circleRadius / 2, 0, 2 * M_PI, 0); // 添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径加填充
}
#pragma mark - touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}
// 滑动结束，调用回调函数
- (void)callbackTouchEnd:(BOOL)isTouchEnd {
    self.isSliding = ! isTouchEnd;
    if (_touchBlock)
        _touchBlock(_value, isTouchEnd);
}
// 根据滑动后的value更新
- (void)updateTouchPoint:(NSSet*)touches {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.scaleNum = (_direction == LSliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == LSliderDirectionHorizonal ? self.width : self.height);
}
// 重写setMinValue，设置value的初始值
- (void)setMinValue:(CGFloat)minValue {
    if (_minValue != minValue) {
        _minValue = minValue;
        _value = minValue;
    }
}
// 设置滑动的比值
- (void)setScaleNum:(CGFloat)scaleNum {
    if (_scaleNum != scaleNum) {
        _scaleNum = scaleNum;
        self.value = _minValue + scaleNum * (_maxValue - _minValue);
    }
}

@end
