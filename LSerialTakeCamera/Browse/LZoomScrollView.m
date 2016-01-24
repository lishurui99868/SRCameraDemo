//
//  LZoomScrollView.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 22/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LZoomScrollView.h"

@implementation LZoomScrollView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_createZoomScrollView];
    }
    return self;
}

- (void)p_createZoomScrollView {
    self.delegate = self;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 3;
    _zoomImageView = [[UIImageView alloc]init];
    _zoomImageView.userInteractionEnabled = YES;
    [self addSubview:_zoomImageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _zoomImageView;
}

@end
