//
//  LBrowseView.m
//  LSerialTakeCamera
//
//  Created by 李姝睿 on 22/1/16.
//  Copyright © 2016年 李姝睿. All rights reserved.
//
#define kSpace 50.0f

#import "LBrowseView.h"
#import "LBrowsCollectionViewCell.h"

@interface LBrowseView ()

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, assign) NSInteger currentIndex;

@end
@implementation LBrowseView

- (id)initWithImagesArray:(NSArray *)imagesArray currentIndex:(NSInteger)currentIndex {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _imagesArray = imagesArray;
        _currentIndex = currentIndex;
        [self p_createBrowsView];
    }
    return self;
}

- (void)p_createBrowsView {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0f;
    }];
    [self p_createCollectionView];
}

- (void)p_createCollectionView {
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.itemSize = CGSizeMake(self.width + kSpace, self.height);
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 0;
    // 每行的间距
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width + kSpace, self.height) collectionViewLayout:flowLayout];
    [self addSubview:_collectionView];
    //cell注册
    [_collectionView registerClass:[LBrowsCollectionViewCell class] forCellWithReuseIdentifier:@"Browser_Cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.contentOffset = CGPointMake(_currentIndex * (self.width + kSpace), 0);
    _collectionView.backgroundColor = [UIColor blackColor];
}
#pragma mark collectionDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBrowsCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Browser_Cell" forIndexPath:indexPath];
    if (cell) {
        cell.zoomScrollView.zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
        // 还原初始缩放比例
        cell.zoomScrollView.zoomScale = 1.0f;
        // 将scrollview的contentSize和imageView的frame还原成缩放前
        cell.zoomScrollView.contentSize = CGSizeMake(self.width, self.height);
        cell.zoomScrollView.zoomImageView.frame = cell.zoomScrollView.bounds;
        cell.zoomScrollView.zoomImageView.image = _imagesArray[indexPath.item];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [cell addGestureRecognizer:tap];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imagesArray.count;
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        // imageView设置为填满并切去多于的边
        [self removeFromSuperview];
    }];
}

@end
