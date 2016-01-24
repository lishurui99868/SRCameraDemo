//
//  LPhotoCollectionViewCell.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 19/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>
/**已经拖动图片*/
typedef void(^LPhotoCollectionViewCellDidPan)(void);
/**是否可以拖动图片*/
typedef BOOL(^LPhotoCollectionViewCellCanPan)(void);
/**将要拖动图片*/
typedef void(^LPhotoCollectionViewCellWillPan)(void);
/**点击图片*/
typedef void(^LPhotoCollectionViewCellTap)(void);

@interface LPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * photoImageView;
@property (nonatomic, strong) UIPanGestureRecognizer * pan;

- (void)didPanPhotoImageView:(LPhotoCollectionViewCellDidPan)block;
- (void)canPanPhotoImageView:(LPhotoCollectionViewCellCanPan)block;
- (void)willPanPhotoImageView:(LPhotoCollectionViewCellWillPan)block;
- (void)tapPhotoImageView:(LPhotoCollectionViewCellTap)block;


@end
