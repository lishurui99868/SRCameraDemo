//
//  LRootViewController.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 18/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "LRootViewController.h"
#import "LCameraViewController.h"

@interface LRootViewController ()<UITableViewDataSource,UITableViewDelegate, LCameraViewControllerDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation LRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"连拍相机";
    [self createTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)createTableView {
    _tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}
#pragma mrak - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentify = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (! cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    cell.textLabel.text = @"Open SerialCamera";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    LCameraViewController * ctr = [[LCameraViewController alloc]init];
    ctr.delegate = self;
    [self presentViewController:ctr animated:YES completion:nil];
}

- (void)cameraViewControllerSavePhotos:(NSArray *)images finish:(LCameraViewControllerSaveFinishBlock)finish {
    finish();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
