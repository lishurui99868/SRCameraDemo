//
//  LCameraView.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class LCameraView;

@protocol LCameraViewDelegate <NSObject>
@optional
/**
 *  聚焦
 */
- (void)cameraView:(LCameraView *)camera focusAtPoint:(CGPoint)point;
/**
 *  曝光
 */
- (void)cameraView:(LCameraView *)camera exposeAtPoint:(CGPoint)point;
/**
 *  镜头伸缩
 */
- (void)cameraView:(LCameraView *)camera pinchForScale:(CGFloat)scale;
/**
 *  拍照
 */
- (void)cameraViewStartRecording;
/**
 *  退出相机
 */
- (void)closeCamera;
/**
 *  切换摄像头
 */
- (void)switchCamera;
/**
 *  切换闪光灯
 */
- (void)triggerFlashForMode:(AVCaptureFlashMode)flashMode;
/**
 *  保存照片
 */
- (void)savePhotoes;

@end
@interface LCameraView : UIView
/**预览图层，来显示照相机拍摄到的画面*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
/**delegate*/
@property (nonatomic, weak)  id<LCameraViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * imageArray;

- (instancetype)initWithCaptureSession:(AVCaptureSession *)session;

- (void)drawFocusLayerAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void)drawExposeLayerAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove;
- (void)pinchPreviewLayerWithScale:(CGFloat)scaleNum;

@end
