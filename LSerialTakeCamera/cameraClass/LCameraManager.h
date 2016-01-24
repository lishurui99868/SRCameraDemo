//
//  LCameraManager.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol LCameraManagerDelegate <NSObject>
/**
 *  生成照片结束
 */
- (void)captureImageDidFinish:(UIImage *)image;
/**
 *  生成照片失败
 */
- (void)captureImageFailedWithError:(NSError *)error;
- (void)someOtherError:(NSError *)error;
- (void)acquiringDeviceLockFailedWithError:(NSError *)error;
- (void)captureSessionDidStartRunning;

@end
@interface LCameraManager : NSObject
/**AVCaptureSession对象来执行输入设备和输出设备之间的数据传递*/
@property (nonatomic, readonly, strong) AVCaptureSession * session;
/**AVCaptureDeviceInput对象是输入流，调用所有的输入硬件。例如摄像头和麦克风*/
@property (nonatomic, readonly, strong) AVCaptureDeviceInput * videoInput;
/**照片输出流对象，AVCaptureStillImageOutput用于输出图像*/
@property (nonatomic, strong) AVCaptureStillImageOutput * stillImageOutput;
/**前置和后置摄像头*/
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;
/**闪光灯开关*/
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
/**手电筒开关*/
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
/**焦距调整*/
@property (nonatomic, assign) AVCaptureFocusMode focusMode;
/**曝光量调节*/
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;
/**白平衡*/
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
/**摄像头个数*/
@property (nonatomic, assign, readonly) NSUInteger cameraCount;
/**delegate*/
@property (nonatomic, weak) id<LCameraManagerDelegate> delegate;
/**
 *  切换前后摄像头
 */
- (BOOL)cameraToggle;
/**
 *  是否能调整焦距
 */
- (BOOL)hasFocus;
/**
 *  可否调节曝光量
 */
- (BOOL)hasExposure;
/**
 *  可否调节白平衡
 */
- (BOOL)hasWhiteBalance;

- (BOOL)setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
/**
 *  开始运行
 */
- (void)startRunning;
/**
 *  停止运行
 */
- (void)stopRunning;
/**
 *  根据设备方向生成图片
 */
- (void)captureImageForDeviceOrientation:(UIDeviceOrientation)deviceOrientation andScale:(CGFloat)scaleNum;
- (CGFloat)getMaxScal;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;
/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer;


@end
