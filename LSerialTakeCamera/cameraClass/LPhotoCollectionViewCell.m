//
//  LPhotoCollectionViewCell.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 19/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LPhotoCollectionViewCell.h"

@interface LPhotoCollectionViewCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, copy) LPhotoCollectionViewCellDidPan didPanBlock;
@property (nonatomic, copy) LPhotoCollectionViewCellCanPan canPanBlock;
@property (nonatomic, copy) LPhotoCollectionViewCellWillPan willPanBlock;
@property (nonatomic, copy) LPhotoCollectionViewCellTap tapBlock;
/**点击手势*/
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end
@implementation LPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        [self createUI];
    return self;
}

- (void)createUI {
    _photoImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:_photoImageView];
    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    _photoImageView.userInteractionEnabled = YES;
    // 添加拖拽手势
    _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    _pan.delegate = self;
    _pan.minimumNumberOfTouches = 1;
    _pan.maximumNumberOfTouches = 1;
    [_photoImageView addGestureRecognizer:_pan];
    // 添加点击手势
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [_photoImageView addGestureRecognizer:_tap];
}

- (void)layoutSubviews {
    _photoImageView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
}
#pragma mark - GestureRecognizerActions
- (void)panAction:(UIPanGestureRecognizer *)pan {
    BOOL canPan = _canPanBlock();
    if (! canPan) {
        pan.enabled = NO;
        pan.enabled = YES;
        return;
    }
    if (pan.state == UIGestureRecognizerStateBegan)
        _willPanBlock();
    if (_didPanBlock)
        _didPanBlock();
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    if(_tapBlock)
        _tapBlock();
}
#pragma mark - horizontal pan gesture methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.contentView];
        if (fabsf(velocity.x) < fabsf(velocity.y))
            return YES;
    }
    return NO;
}
#pragma mark - blockMethods
- (void)didPanPhotoImageView:(LPhotoCollectionViewCellDidPan)block {
    _didPanBlock = block;
}

- (void)willPanPhotoImageView:(LPhotoCollectionViewCellWillPan)block {
    _willPanBlock = block;
}

- (void)canPanPhotoImageView:(LPhotoCollectionViewCellCanPan)block {
    _canPanBlock = block;
}

- (void)tapPhotoImageView:(LPhotoCollectionViewCellTap)block {
    _tapBlock = block;
}

@end
