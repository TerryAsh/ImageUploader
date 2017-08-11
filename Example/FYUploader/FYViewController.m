//
//  FYViewController.m
//  FYUploader
//
//  Created by Ash on 08/10/2017.
//  Copyright (c) 2017 Ash. All rights reserved.
//
@import ZLPhotoBrowser;
@import SDWebImage;
@import FrameAccessor;
#import "FYViewController.h"
#import <FYUploader/FYImageUploader.h>
#import <FYUploader/FYPhotoBrowseViewController.h>
#import <Photos/Photos.h>

@interface FYViewController ()<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) FYImageUploader *uploader;
@property (nonatomic ,strong) UIImageView *imageView;
@end

@implementation FYViewController
static NSString *CellID = @"CellID";

- (UITableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInsetTop = self.imageView.height-  (self.navigationController ? 64 : 0);
        [_tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:CellID];
    }
    return _tableView;
}

- (UIImageView *)imageView{
    if (nil == _imageView) {
        CGFloat width = self.view.width;
        CGFloat height = width * (3 / 4.);
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _imageView.backgroundColor = [UIColor redColor];
       [_imageView sd_setImageWithURL:[NSURL URLWithString:@"http://ashit.qiniudn.com/c30605bd-72a9-4b48-a989-11ee405ff0f8.jpg_600x450.jpg"]];
    }
    return _imageView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [FYImageModel clearAllImageModel];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self _layoutViews];
    return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"标题" message:@"摇一摇，有惊喜" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)_layoutViews{
    [self.view addSubview:self.tableView];

    [self.view addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.uploader.uploadingImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID
                                                            forIndexPath:indexPath];
    FYImageModel *img = self.uploader.uploadingImages[indexPath.row];
    if (img.localPath) {
        cell.imageView.image = [UIImage imageWithContentsOfFile:img.localPath];
    } else {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:img.urlString]];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%.2lf%%",img.fractionCompleted * 100];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat offsetY =  sender.contentOffset.y;
    CGFloat width = self.view.width;
    CGFloat defaultHeight = width * (3 / 4.);
    NSLog(@"%lf,%lf",offsetY,defaultHeight);
    
    
    
    
    if (offsetY <= -defaultHeight) {
        CGFloat offset = offsetY * -1.;
        CGFloat finalHeight = offset;
        CGFloat finalWidth = finalHeight * (4. /3);
        self.imageView.viewSize = CGSizeMake(finalWidth, finalHeight);
        self.imageView.centerX = self.view.centerX;
    } else if (offsetY < defaultHeight ){
        CGFloat finalHeight =  - offsetY;
        if (finalHeight > 0.) {
            self.imageView.bottom = finalHeight;
        }
    }
}


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 20;
    //设置照片最大选择数
    actionSheet.maxSelectCount = 10;
    actionSheet.sender = self;
    
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        
        // prepare to upload
        __block NSMutableArray<FYImageModel *> *models = [NSMutableArray new];
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            CGSize size = isOriginal ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            // 同步获得图片, 只会返回1张图片
            options.synchronous = YES;
            // 从asset中获得图片
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                NSLog(@"%@,%s",info,__func__);
                NSString *name = [NSUUID UUID].UUIDString;
                FYImageModel *imageModel = [FYImageModel imageModelWithUIImage:result
                                                                  andImageName:name];
                imageModel.title = name;
                if (imageModel) {
                    [models addObject:imageModel];
                }
            }];
        }];
        
        NSArray<NSString *> *urls = @[@"http://ashit.qiniudn.com/nba_GS.png",
                                      @"http://ashit.qiniudn.com/raptor.png"];
        [urls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FYImageModel *urlImage = [FYImageModel imageModelFromUrl:obj];
            urlImage.title = [NSString stringWithFormat:@"网图%ld",idx];
            [models addObject:urlImage];
        }];
        
//        FYPhotoBrowseViewController *browseVC = [FYPhotoBrowseViewController new];
//        [self presentViewController:browseVC animated:YES completion:^{
//            browseVC.imageModels = models;
//        }];
        
        // begin upload
        _uploader = [[FYImageUploader alloc] initWithImageModels:models];
        [self.tableView reloadData];

//        [_uploader startWithCallBack:^(FYImageUploader *uploader) {
//            [uploader.uploadingImages enumerateObjectsUsingBlock:^(FYImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            }];
//        }];
    }];
    
    [actionSheet showPreviewAnimated:YES];
}


@end
