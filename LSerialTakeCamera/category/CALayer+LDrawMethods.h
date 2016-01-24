//
//  CALayer+LDrawMethods.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 22/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (LDrawMethods)

- (void)drawAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void)pinchWithScaleNum:(CGFloat)scaleNum;

@end
