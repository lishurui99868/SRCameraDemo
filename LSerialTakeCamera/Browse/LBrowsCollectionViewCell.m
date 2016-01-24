//
//  LBrowsCollectionViewCell.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 22/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LBrowsCollectionViewCell.h"

@implementation LBrowsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_createUI];
    }
    return self;
}

- (void)p_createUI {
    _zoomScrollView = [[LZoomScrollView alloc]init];
    [self.contentView addSubview:_zoomScrollView];
    _zoomScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}


@end
