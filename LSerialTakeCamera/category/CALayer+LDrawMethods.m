//
//  CALayer+LDrawMethods.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 22/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "CALayer+LDrawMethods.h"

@implementation CALayer (LDrawMethods)

- (void)drawAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove {
    if (remove)
        [self removeAllAnimations];
    if ([self animationForKey:@"transform.scale"] == nil && [self animationForKey:@"opacity"] == nil) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        self.position = point;
        [CATransaction commit];
        
        CABasicAnimation * scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = [NSNumber numberWithFloat:1];
        scale.toValue = [NSNumber numberWithFloat:0.7];
        scale.duration = 0.8;
        scale.removedOnCompletion = YES;
        
        CABasicAnimation * opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.fromValue = [NSNumber numberWithFloat:1];
        opacity.toValue = [NSNumber numberWithFloat:0];
        opacity.duration = 0.8;
        opacity.removedOnCompletion = YES;
        
        [self addAnimation:scale forKey:@"transform.scale"];
        [self addAnimation:opacity forKey:@"opacity"];
    }
}

- (void)pinchWithScaleNum:(CGFloat)scaleNum {
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025f];
    self.affineTransform = CGAffineTransformMakeScale(scaleNum, scaleNum);
    [CATransaction commit];
}

@end
