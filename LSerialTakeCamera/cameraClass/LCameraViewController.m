//
//  LCameraViewController.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LCameraViewController.h"
#import "LCameraManager.h"
#import "LCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface LCameraViewController ()<LCameraManagerDelegate, LCameraViewDelegate>
/**设备方向*/
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, assign) BOOL processingPhoto;
@property (nonatomic, strong) LCameraView * cameraView;
@property (nonatomic, strong) LCameraManager * cameraManager;
@property (nonatomic, assign) CGFloat scaleNum;
@property (nonatomic, strong) CMMotionManager * motionManager;

@end

@implementation LCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    _scaleNum = 1.f;
    [self initManagerAndCameraView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_cameraManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.0];
    [self startMotionManager];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_cameraManager performSelector:@selector(stopRunning) withObject:nil afterDelay:0.0];
    [_motionManager stopDeviceMotionUpdates];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _cameraManager = nil;
}
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#pragma mark - motionManager
- (void)startMotionManager {
    if (! _motionManager)
        _motionManager = [[CMMotionManager alloc]init];
    _motionManager.deviceMotionUpdateInterval = 1 / 15.0;
    if (_motionManager.deviceMotionAvailable)
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    else
        _motionManager = nil;
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion {
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0)
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        else
            _deviceOrientation = UIDeviceOrientationPortrait;
    } else {
        if (x >= 0)
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
        else
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
}

- (void)initManagerAndCameraView {
    _cameraManager = [[LCameraManager alloc]init];
    _cameraManager.delegate = self;
    NSError * error;
    if ([_cameraManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error]) {
        _cameraView = [[LCameraView alloc]initWithCaptureSession:_cameraManager.session];
        _cameraView.delegate = self;
        [self.view addSubview:_cameraView];
    }
}

- (void)setScaleNum:(CGFloat)scaleNum {
    _scaleNum = scaleNum;
    if (_scaleNum < MIN_PINCH_SCALE_NUM)
        _scaleNum = MIN_PINCH_SCALE_NUM;
    else if (_scaleNum > MAX_PINCH_SCALE_NUM)
        _scaleNum = MAX_PINCH_SCALE_NUM;
}
#pragma mark - cameraManagerDelegate
- (void)captureImageDidFinish:(UIImage *)image {
    _processingPhoto = NO;
    [_cameraView.imageArray addObject:image];
    if (_cameraView.imageArray.count)
        _cameraView.collectionView.hidden = NO;
    [_cameraView.collectionView reloadData];
    if (_cameraView.imageArray.count > 4)
        [_cameraView.collectionView setContentOffset:CGPointMake((_cameraView.imageArray.count - 4) * 78, 0) animated:YES];
}

- (void)captureImageFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    });
}

- (void)captureSessionDidStartRunning {
    CGPoint screenCenter = CGPointMake(_cameraView.width * 0.5f, _cameraView.height * 0.5f - CGRectGetMinY(_cameraView.previewLayer.frame));
    if ([_cameraView respondsToSelector:@selector(drawFocusLayerAtPointOfInterest:andRemove:)] )
        [_cameraView drawFocusLayerAtPointOfInterest:screenCenter andRemove:NO];
    if ([_cameraView respondsToSelector:@selector(drawExposeLayerAtPointOfInterest:andRemove:)] )
        [_cameraView drawExposeLayerAtPointOfInterest:screenCenter andRemove:NO];
}
#pragma mark - cameraViewDelegate
// 切换闪光灯
- (void)triggerFlashForMode:(AVCaptureFlashMode)flashMode {
    if (_cameraManager.videoInput.device.hasFlash)
        _cameraManager.flashMode = flashMode;
}
// 切换摄像头
- (void)switchCamera {
    [_cameraManager cameraToggle];
}
// 退出相机
- (void)closeCamera {
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 拍照
- (void)cameraViewStartRecording {
    if (_processingPhoto)
        return;
    _processingPhoto = YES;
    [_cameraManager captureImageForDeviceOrientation:_deviceOrientation andScale:_scaleNum];
}
// 对焦
- (void)cameraView:(LCameraView *)camera focusAtPoint:(CGPoint)point {
    if (_cameraManager.videoInput.device.isFocusPointOfInterestSupported) {
        [_cameraManager focusAtPoint:[_cameraManager convertToPointOfInterestFrom:camera.previewLayer.frame coordinates:point layer:camera.previewLayer]];
        [camera drawFocusLayerAtPointOfInterest:point andRemove:YES];
    }
}
// 曝光
- (void)cameraView:(LCameraView *)camera exposeAtPoint:(CGPoint)point {
    if (_cameraManager.videoInput.device.isExposurePointOfInterestSupported) {
        [_cameraManager exposureAtPoint:[_cameraManager convertToPointOfInterestFrom:camera.previewLayer.frame coordinates:point layer:camera.previewLayer]];
        [camera drawExposeLayerAtPointOfInterest:point andRemove:YES];
    }
}
// 伸缩镜头
- (void)cameraView:(LCameraView *)camera pinchForScale:(CGFloat)scale {
    self.scaleNum = scale;
    if (_scaleNum > [_cameraManager getMaxScal])
        _scaleNum = [_cameraManager getMaxScal];
    [camera pinchPreviewLayerWithScale:_scaleNum];
}

- (void)savePhotoes {
    for (UIImage * image in _cameraView.imageArray) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    WS(ws)
    if ([_delegate respondsToSelector:@selector(cameraViewControllerSavePhotos:finish:)])
        [_delegate cameraViewControllerSavePhotos:_cameraView.imageArray finish:^{
            [ws dismissViewControllerAnimated:YES completion:nil];
        }];
}
#pragma mark - UIApplicationDidEnterBackgroundNotification
- (void) applicationDidEnterBackground:(NSNotification *)notification {
    id modalViewController = self.presentingViewController;
    if (modalViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
