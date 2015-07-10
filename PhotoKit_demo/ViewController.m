//
//  ViewController.m
//  PhotoKit_demo
//
//  Created by 沈红榜 on 15/7/3.
//  Copyright (c) 2015年 沈红榜. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
//@import Photos;
//#import "UIViewController+image.h"
#import <IDMPhotoBrowser.h>
#import <SVProgressHUD.h>
#import "HZPhotoBrowser.h"
#import <MWPhotoBrowser.h>


@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, HZPhotoBrowserDelegate, MWPhotoBrowserDelegate>
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumls;
@property (nonatomic, strong) NSMutableArray *urls;

@end

@implementation ViewController {
    UICollectionView *_collection;
//    NSMutableArray *_images;
//    NSMutableArray *_photos;
//    NSMutableArray *_thumls;
//    NSMutableArray *_urls;
//    IDMPhotoBrowser *photoBrowser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    [SVProgressHUD showWithStatus:@"I Love You" maskType:SVProgressHUDMaskTypeBlack];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    [self.view addSubview:imgView];
    self.images = [[NSMutableArray alloc] initWithCapacity:0];
    _photos = [[NSMutableArray alloc] initWithCapacity:0];
    _thumls = [[NSMutableArray alloc] initWithCapacity:0];
    _urls = [[NSMutableArray alloc] initWithCapacity:0];
    
    // 列出所有相册智能相册
//    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 列出所有用户创建的相册
//    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    options.includeHiddenAssets = NO;
    options.includeAllBurstAssets = YES;
//    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    // 在资源的集合中获取第一个集合，并获取其中的图片
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    imageManager.allowsCachingHighQualityImages = YES;
    if (assetsFetchResults.count) {
        __weak typeof(self) SHB = self;
        [assetsFetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PHAsset *asset = (PHAsset *)obj;
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *image = [UIImage imageWithData:imageData];
                [SHB.images addObject:image];
                [SHB.thumls addObject:[UIImage imageWithData:imageData scale:0.1]];
                if (assetsFetchResults.count - 1 == idx) {
                    *stop = YES;
                    [_collection reloadData];
                    [SVProgressHUD dismiss];
                }
            }];
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"no photos in album" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake(100, 100);
    _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64) collectionViewLayout:layout];
    _collection.backgroundColor = [UIColor whiteColor];
    _collection.delegate = self;
    _collection.dataSource = self;
    [self.view addSubview:_collection];
    [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    UIImage *image = (UIImage *)_thumls[indexPath.row];
    item.contentView.layer.contents = (__bridge id)image.CGImage;
    return item;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _thumls.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self bigImage:indexPath];
//    IDMPhotoBrowser *photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:_photos animatedFromView:self.view];
//    photoBrowser.displayToolbar = YES;
//    photoBrowser.displayDoneButton = YES;
//    photoBrowser.displayArrowButton = YES;
//    photoBrowser.displayActionButton = YES;
//    photoBrowser.displayCounterLabel = YES;
//    photoBrowser.arrowButtonsChangePhotosAnimated = YES;
//    [photoBrowser setInitialPageIndex:indexPath.row];
//    [self presentViewController:photoBrowser animated:YES completion:nil];
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    [photoBrowser showNextPhotoAnimated:YES];
    [photoBrowser showPreviousPhotoAnimated:YES];
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _images.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    UIImage *image = (UIImage *)_images[index];
    return [MWPhoto photoWithImage:image];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
