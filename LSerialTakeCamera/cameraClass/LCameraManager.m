//
//  LCameraManager.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LCameraManager.h"

@implementation LCameraManager
/**
 *  找到对应的Connection，连接输入(input)和输出(output)
 */
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connectionArray {
    for (AVCaptureConnection * connection in connectionArray)
        for (AVCaptureInputPort * port in connection.inputPorts)
            if ([port.mediaType isEqual:mediaType])
                return connection;
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionDidStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:_session];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_session stopRunning];
    _session = nil;
    _videoInput = nil;
    _stillImageOutput = nil;
}

- (void)captureSessionDidStartRunning:(NSNotification *)notification {
    if ([_delegate respondsToSelector:@selector(captureSessionDidStartRunning)])
        [_delegate captureSessionDidStartRunning];
}

- (BOOL)setupSessionWithPreset:(NSString *)sessionPreset error:(NSError *__autoreleasing *)error {
    // 添加输入设备
    _videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:error];
    // 添加输出设备
    _stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    _stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG}; // 输出jpeg
    // 建立session
    _session = [[AVCaptureSession alloc]init];
    if ([_session canAddInput:_videoInput])
        [_session addInput:_videoInput];
    if ([_session canAddOutput:_stillImageOutput])
        [_session addOutput:_stillImageOutput];
    _session.sessionPreset = sessionPreset; // 设置照片质量
    self.flashMode = AVCaptureFlashModeOff;
    return YES;
}
// 获取前后摄像头对象
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    __block AVCaptureDevice * blockDevice = nil;
    [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVCaptureDevice * device = (AVCaptureDevice *)obj;
        if (device.position == position) {
            blockDevice = device;
            *stop = YES;
        }
    }];
    return blockDevice;
}
/**
 *  根据设备方向生成图片
 */
- (void)captureImageForDeviceOrientation:(UIDeviceOrientation)deviceOrientation andScale:(CGFloat)scaleNum {
    // 获取连接
    AVCaptureConnection * videoConnection = [LCameraManager connectionWithMediaType:AVMediaTypeVideo fromConnections:_stillImageOutput.connections];
    videoConnection.videoScaleAndCropFactor = scaleNum;
    // supportsVideoMirroring 指示连接是否支持videomirrored属性设置
    if (videoConnection.isVideoMirroringSupported) {
        switch (deviceOrientation) {
            case UIDeviceOrientationPortraitUpsideDown: // 竖屏，home键在上
                videoConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIDeviceOrientationLandscapeLeft: // 横屏，home键在右
                videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight: // 横屏，home键在左
                videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            default:
                videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    __weak id<LCameraManagerDelegate> weakDelegate = _delegate;
    // 获取图片
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage * image = [UIImage imageWithData:imageData];
            if ([weakDelegate respondsToSelector:@selector(captureImageDidFinish:)])
                [weakDelegate captureImageDidFinish:image];
        } else if (error) {
            if ([weakDelegate respondsToSelector:@selector(captureImageFailedWithError:)])
                [weakDelegate captureImageFailedWithError:error];
        }
    }];
}
#pragma mark - Informations
- (NSUInteger)cameraCount {
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

- (CGFloat)getMaxScal {
    AVCaptureConnection * videoConnection = [LCameraManager connectionWithMediaType:AVMediaTypeVideo fromConnections:_stillImageOutput.connections];
    return videoConnection.videoMaxScaleAndCropFactor;
}
/**
 *  切换前后摄像头
 */
- (BOOL)cameraToggle {
    BOOL success = NO;
    if (self.cameraCount > 1) {
        NSError * error;
        AVCaptureDeviceInput * newVideoInput;
        AVCaptureDevicePosition position = _videoInput.device.position;
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:&error];
        else
            goto bail;
        if (newVideoInput != nil) {
            [_session beginConfiguration];
            [_session removeInput:_videoInput];
            if ([_session canAddInput:newVideoInput]) {
                [_session addInput:newVideoInput];
                _videoInput = newVideoInput;
            } else
                [_session addInput:_videoInput];
            [_session commitConfiguration];
            success = YES;
        } else if (error)
            if ([_delegate respondsToSelector:@selector(someOtherError:)])
                [_delegate someOtherError:error];
    }
bail:
    return success;
}
#pragma mark - aboutFlash
- (AVCaptureFlashMode)flashMode {
    return _videoInput.device.flashMode;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice * device = _videoInput.device;
    if ([device isFlashModeSupported:flashMode] && device.flashMode != flashMode) {
        NSError * error;
        // 更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else
            if ([_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)])
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}
#pragma mark - aboutTorch
- (AVCaptureTorchMode)torchMode {
    return _videoInput.device.torchMode;
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice * device = _videoInput.device;
    if ([device isTorchModeSupported:torchMode] && device.torchMode != torchMode ) {
        NSError * error;
        if ( [device lockForConfiguration:&error] ) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}
#pragma mark - aboutWhiteBalance
- (BOOL)hasWhiteBalance {
    AVCaptureDevice * device = _videoInput.device;
    return [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] || [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance];
}

- (AVCaptureWhiteBalanceMode)whiteBalanceMode {
    return _videoInput.device.whiteBalanceMode;
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode {
    if (whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance)
        whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
    AVCaptureDevice * device = _videoInput.device;
    if ([device isWhiteBalanceModeSupported:whiteBalanceMode] && device.whiteBalanceMode != whiteBalanceMode) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.whiteBalanceMode = whiteBalanceMode;
            [device unlockForConfiguration];
        } else
            if ([_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)])
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}
#pragma mark - aboutFocus
- (BOOL)hasFocus {
    AVCaptureDevice * device = _videoInput.device;
    return [device isFocusModeSupported:AVCaptureFocusModeLocked] || [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] || [device isFocusModeSupported:AVCaptureFocusModeAutoFocus];
}

- (AVCaptureFocusMode)focusMode {
    return _videoInput.device.focusMode;
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
    AVCaptureDevice * device = _videoInput.device;
    if ([device isFocusModeSupported:focusMode] && device.focusMode != focusMode) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.focusMode = focusMode;
            [device unlockForConfiguration];
        } else
            if ( [_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)] )
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice * device = _videoInput.device;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else
            if ([_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)])
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}
#pragma mark - aboutExposure
- (BOOL)hasExposure {
    AVCaptureDevice * device = _videoInput.device;
    return [device isExposureModeSupported:AVCaptureExposureModeLocked] || [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] || [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (AVCaptureExposureMode)exposureMode {
    return _videoInput.device.exposureMode;
}

- (void)setExposureMode:(AVCaptureExposureMode)exposureMode {
    if (exposureMode == AVCaptureExposureModeAutoExpose)
        exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureDevice * device = _videoInput.device;
    if ([device isExposureModeSupported:exposureMode] && device.exposureMode != exposureMode) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.exposureMode = exposureMode;
            [device unlockForConfiguration];
        } else
            if ([_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)])
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}

- (void)exposureAtPoint:(CGPoint)point {
    AVCaptureDevice * device = _videoInput.device;
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError * error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device unlockForConfiguration];
        } else
            if ([_delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)])
                [_delegate acquiringDeviceLockFailedWithError:error];
    }
}
/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer {
    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
    CGSize frameSize = frame.size;
    if ([layer.videoGravity isEqualToString:AVLayerVideoGravityResize])
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.0f - (viewCoordinates.x / frameSize.width));
    else {
        CGRect cleanAperture;
        for (AVCaptureInputPort * port in self.videoInput.ports) {
            if (port.mediaType == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture(port.formatDescription, YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = 0.5f;
                CGFloat yc = 0.5f;
                if ([layer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.0f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.0f - (point.x / x2);
                        }
                    }
                } else if ([layer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.0f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.0f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    return pointOfInterest;
}

- (void)startRunning {
    [_session startRunning];
}

- (void)stopRunning {
    [_session stopRunning];
}

@end
