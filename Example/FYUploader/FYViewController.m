//
//  FYViewController.m
//  FYUploader
//
//  Created by Ash on 08/10/2017.
//  Copyright (c) 2017 Ash. All rights reserved.
//
@import ZLPhotoBrowser;
#import "FYViewController.h"
#import <FYUploader/FYImageUploader.h>
#import <Photos/Photos.h>

@interface FYViewController ()<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) FYImageUploader *uploader;

@end

@implementation FYViewController
static NSString *CellID = @"CellID";

- (UITableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:CellID];
    }
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"标题" message:@"摇一摇，有惊喜" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.uploader.uploadingImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID
                                                            forIndexPath:indexPath];
    FYImageModel *img = self.uploader.uploadingImages[indexPath.row];
    cell.imageView.image = [UIImage imageWithContentsOfFile:img.localPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%.2lf%%",img.fractionCompleted * 100];
    return cell;
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
                if (imageModel) {
                    [models addObject:imageModel];
                }
            }];
        }];
        // begin upload
        _uploader = [[FYImageUploader alloc] initWithImageModels:models];
        [_uploader startWithCallBack:^(FYImageUploader *uploader) {
            [uploader.uploadingImages enumerateObjectsUsingBlock:^(FYImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }];
        }];
    }];
    
    [actionSheet showPreviewAnimated:YES];
}


@end
