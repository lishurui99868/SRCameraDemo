//
//  LCameraView.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//
#define kBtnHeight 50
#define kColletionViewHeight 104
#define kMaxCount 10
#import "LCameraView.h"
#import "LSlider.h"
#import "LBrowseView.h"
#import "LPhotoCollectionViewCell.h"

@interface LCameraView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
/**对焦*/
@property (nonatomic, strong) CALayer * focusLayer;
/**曝光补偿*/
@property (nonatomic, strong) CALayer * exposeLayer;
/**闪光灯状态*/
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
/**当前的拖拽的cell*/
@property (nonatomic, strong) LPhotoCollectionViewCell * currentCell;
/**滑动条*/
@property (nonatomic, strong) LSlider * slider;
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;
@end
@implementation LCameraView

- (instancetype)initWithCaptureSession:(AVCaptureSession *)session {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        _imageArray = [NSMutableArray array];
        _flashMode = AVCaptureFlashModeOff;
        _preScaleNum = 1.f;
        [self createPreviewLayerWithSession:session];
        [self createUI];
        [self createCollectionView];
        [self createLayers];
        [self createGestures];
    }
    return self;
}
#pragma mark - UI
- (void)createPreviewLayerWithSession:(AVCaptureSession *)session {
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    _previewLayer.frame = CGRectMake(0, 0, self.width, self.height - kBtnHeight - kColletionViewHeight);
    if ([_previewLayer respondsToSelector:@selector(connection)])
        if ([_previewLayer.connection isVideoOrientationSupported])
            _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_previewLayer];
}

- (void)createUI {
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - kBtnHeight, self.width, kBtnHeight)];
    view.backgroundColor = [UIColor blackColor];
    [self addSubview:view];
    // 闪光灯
    UIButton * flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setNormalImage:@"ellipse-0"];
    flashBtn.frame = CGRectMake(15, 15, 40, 40);
    [flashBtn addTarget:self action:@selector(flashTriggerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:flashBtn];
    flashBtn.tag = 998;
    // 切换摄像头
    UIButton * cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setNormalImage:@"camera"];
    cameraBtn.frame = CGRectMake(self.width - 55, 15, 40, 40);
    [cameraBtn addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraBtn];
    // 取消按钮
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, self.height - kBtnHeight, 80, kBtnHeight);
    [cancelBtn setNormalTitle:@"取消" andTitleColor:[UIColor whiteColor]];
    [cancelBtn addTarget:self action:@selector(cancelTakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    // 拍照按钮
    UIButton * takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    takeBtn.frame = CGRectMake(self.midX - 30, self.height - kBtnHeight, kBtnHeight, kBtnHeight);
    [takeBtn setNormalImage:@"curcle"];
    [takeBtn addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:takeBtn];
    // 保存按钮
    UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(self.width - 80, cancelBtn.minY, 80, kBtnHeight);
    [saveBtn setNormalTitle:@"保存" andTitleColor:[UIColor whiteColor]];
    [saveBtn addTarget:self action:@selector(savePhotos) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveBtn];
    // 提示
    UILabel * promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_previewLayer.frame), self.width, kColletionViewHeight)];
    [promptLabel setLabelTextColor:[UIColor whiteColor] andFont:18.f andText:@"你拍摄的照片会在这里显示。\n向上滑动删除。" andAlignment:NSTextAlignmentCenter];
    promptLabel.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:promptLabel];
    // 滑动条
    _slider = [[LSlider alloc]initWithFrame:CGRectMake(self.width - 40, 80, 40, CGRectGetHeight(_previewLayer.frame) - 100) andDirection:LSliderDirectionVertical];
    _slider.alpha = 0.f;
    _slider.minValue = MIN_PINCH_SCALE_NUM;
    _slider.maxValue = MAX_PINCH_SCALE_NUM;
    WS(ws)
    [_slider didChangeValueBlock:^(CGFloat value) {
        if ([ws.delegate respondsToSelector:@selector(cameraView:pinchForScale:)])
            [ws.delegate cameraView:ws pinchForScale:value];
    }];
    [_slider touchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [ws setSliderAlpha:isTouchEnd];
    }];
    [self addSubview:_slider];
}

- (void)createCollectionView {
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(78, 100);
    flowLayout.sectionInset = UIEdgeInsetsMake(2, 0, 2, 0);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_previewLayer.frame), self.width, kColletionViewHeight) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.clipsToBounds = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.hidden = YES;
    [_collectionView registerClass:[LPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"photo"];
    [self addSubview:_collectionView];
}

- (void)createLayers {
    // 对焦
    _focusLayer = [[CALayer alloc] init];
    _focusLayer.bounds = CGRectMake(0, 0, 80, 80);
    _focusLayer.borderWidth = 1.0f;
    _focusLayer.borderColor = [UIColor redColor].CGColor;
    _focusLayer.opacity = 0;
    [_previewLayer addSublayer:_focusLayer];
    // 曝光
    _exposeLayer = [[CALayer alloc] init];
    _exposeLayer.bounds = CGRectMake(0, 0, 100, 100);
    _exposeLayer.borderWidth = 2.f;
    _exposeLayer.borderColor = [UIColor yellowColor].CGColor;
    _exposeLayer.opacity = 0;
    [_previewLayer addSublayer:_exposeLayer];
}

- (void)createGestures {
    // 单击
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    // 捏合
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinch];
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    _slider.isSliding = ! isTouchEnd;
    if (_slider.alpha != 0.f && ! _slider.isSliding) {
        double delayInSeconds = 3.88;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_slider.alpha != 0.f && ! _slider.isSliding)
                [UIView animateWithDuration:0.3f animations:^{
                    _slider.alpha = 0.f;
                }];
        });
    }
}
#pragma mark - btnsActions
// 闪光灯切换
- (void)flashTriggerAction:(UIButton *)btn {
    if (_flashMode == AVCaptureFlashModeAuto)
        _flashMode = AVCaptureFlashModeOff;
    else
        _flashMode ++;
    [btn setNormalImage:[NSString stringWithFormat:@"ellipse-%ld",(long)_flashMode]];
    if ([_delegate respondsToSelector:@selector(triggerFlashForMode:)])
        [_delegate triggerFlashForMode:_flashMode];
}
// 摄像头切换
- (void)changeCamera:(UIButton *)btn {
    btn.selected = ! btn.isSelected;
    UIButton * flashBtn = (UIButton *)[self viewWithTag:998];
    if (btn.isSelected) {
        _flashMode = AVCaptureFlashModeAuto;
        [self flashTriggerAction:flashBtn];
    }
    flashBtn.enabled = ! btn.isSelected;
    if ([_delegate respondsToSelector:@selector(switchCamera)] )
        [_delegate switchCamera];
}
// 拍照
- (void)takePhotoAction:(UIButton *)btn {
    if (_imageArray.count < kMaxCount) {
        if ([_delegate respondsToSelector:@selector(cameraViewStartRecording)])
            [_delegate cameraViewStartRecording];
    } else
        [[[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多连拍%d张",(int)kMaxCount] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}
// 取消
- (void)cancelTakePhoto {
    if ([_delegate respondsToSelector:@selector(closeCamera)])
        [_delegate closeCamera];
}
// 保存
- (void)savePhotos {
    if ([_delegate respondsToSelector:@selector(savePhotoes)])
        [_delegate savePhotoes];
}
#pragma mark - GestureRecognizerActions
- (void)tapAction:(UIGestureRecognizer *)recognizer {
    CGPoint tempPoint = [recognizer locationInView:self];
    if ([_delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] && CGRectContainsPoint(_previewLayer.frame, tempPoint))
        [_delegate cameraView:self focusAtPoint:CGPointMake(tempPoint.x, tempPoint.y - CGRectGetMinY(_previewLayer.frame))];
    if ([_delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] && CGRectContainsPoint(_previewLayer.frame, tempPoint))
        [_delegate cameraView:self exposeAtPoint:CGPointMake(tempPoint.x, tempPoint.y - CGRectGetMinY(_previewLayer.frame))];
}
// 伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    BOOL allTouchesOnThePreviewLayer = YES;
    for (NSInteger i = 0; i < recognizer.numberOfTouches; ++ i) {
        CGPoint location = [recognizer locationOfTouch:i inView:self];
        CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
        if (! [_previewLayer containsPoint:convertedLocation]) {
            allTouchesOnThePreviewLayer = NO;
            break;
        }
    }
    if (allTouchesOnThePreviewLayer) {
        if ([_delegate respondsToSelector:@selector(cameraView:pinchForScale:)])
            [_delegate cameraView:self pinchForScale:_preScaleNum * recognizer.scale];
    }
    WS(ws)
    if (_slider.alpha != 1.f)
        [UIView animateWithDuration:0.3f animations:^{
            ws.slider.alpha = 1.f;
        }];
    [_slider setValue:_scaleNum shouldCallBack:NO];
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        [self setSliderAlpha:YES];
        _preScaleNum = _scaleNum;
    }
    else
        [self setSliderAlpha:NO];
}

- (void)drawFocusLayerAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove {
    [_focusLayer drawAtPointOfInterest:point andRemove:remove];
}

- (void)drawExposeLayerAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove {
    [_exposeLayer drawAtPointOfInterest:point andRemove:YES];
}

- (void)pinchPreviewLayerWithScale:(CGFloat)scaleNum {
    [_previewLayer pinchWithScaleNum:scaleNum];
    _scaleNum = scaleNum;
}
#pragma mark collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellId = @"photo";
    LPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.photoImageView.image = _imageArray[indexPath.item];
    cell.photoImageView.tag = indexPath.row + 666;
    WS(ws)
    [cell willPanPhotoImageView:^{
        ws.currentCell = cell;
    }];
    [cell willPanPhotoImageView:^{
        ws.currentCell = cell;
    }];
    [cell canPanPhotoImageView:^BOOL{
        if ([ws.currentCell isEqual:cell] || ! ws.currentCell)
            return YES;
        return NO;
    }];
    [cell didPanPhotoImageView:^{
        [ws didPanCell:cell forIndexPath:indexPath];
    }];
    [cell tapPhotoImageView:^{
        [ws tapBrowse:indexPath];
    }];
    return cell;
}
// 图片浏览
- (void)tapBrowse:(NSIndexPath *)indexPath {
    LBrowseView *browseView = [[LBrowseView alloc]initWithImagesArray:_imageArray currentIndex:indexPath.row];
    [[UIApplication sharedApplication].keyWindow addSubview:browseView];
}

- (void)didPanCell:(LPhotoCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    UIImageView * imageView = (UIImageView *)cell.pan.view;
    CGPoint oldCenter = imageView.center;
    CGPoint translite = [cell.pan translationInView:cell.contentView];
    imageView.center = CGPointMake(oldCenter.x, oldCenter.y + translite.y);
    if (cell.pan.state == UIGestureRecognizerStateEnded) {
        _currentCell = nil;
        if (imageView.minY < - 100) {
            [_imageArray removeObjectAtIndex:indexPath.item];
            if (_imageArray.count == 0)
                _collectionView.hidden = YES;
            [_collectionView reloadData];
        }
        imageView.y = 0;
    }
    [cell.pan setTranslation:CGPointZero inView:self];
}

@end
