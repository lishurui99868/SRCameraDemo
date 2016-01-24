//
//  LCameraViewController.h
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LCameraViewControllerSaveFinishBlock)(void);

@protocol LCameraViewControllerDelegate <NSObject>

- (void)cameraViewControllerSavePhotos:(NSArray *)images finish:(LCameraViewControllerSaveFinishBlock)finish;

@end
@interface LCameraViewController : UIViewController

@property (nonatomic, weak) id<LCameraViewControllerDelegate> delegate;

@end
