//
//  FYPhotoBrowseViewController.m
//  Pods
//
//  Created by 陈震 on 2017/8/11.
//
//

#import "FYPhotoBrowseViewController.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

static NSString *kBrowseCellID = @"BrowseCellID";

@interface FYPhotoBrowseViewController ()<UICollectionViewDelegate ,UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic ,strong) UICollectionViewFlowLayout *layout;

@property (nonatomic ,strong) UIToolbar *toolBar;
@property (nonatomic ,strong) UILabel *titleLabel;

@property (nonatomic ,strong) UILabel *pageTipLabel;

@property (nonatomic ,strong) UIPinchGestureRecognizer *fingerPinch;
@property (assign) CGPoint centerPoint;
@property (nonatomic ,assign) BOOL hasPinched;

@end

@implementation FYPhotoBrowseViewController

- (instancetype)init{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _fingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handleFingerPinch:)];
        [self.collectionView addGestureRecognizer:_fingerPinch];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self _layoutViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_layoutViews{
    [self.pageTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-10);
        make.width.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.toolBar).offset(-140);
        make.height.mas_equalTo(15);
        make.centerX.equalTo(self.toolBar);
        make.bottom.equalTo(self.toolBar).offset(-15);
    }];
}

#pragma mark --setter getter
- (void)setImageModels:(NSArray<FYImageModel *> *)imageModels{
    _imageModels = imageModels;
    [self.collectionView reloadData];
    
    self.pageTipLabel.text = [NSString stringWithFormat:@"%d/%ld",1,self.imageModels.count];
    self.title = imageModels[0].title;
}

- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (UILabel *)pageTipLabel{
    if(!_pageTipLabel){
        _pageTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
        _pageTipLabel.textAlignment = NSTextAlignmentCenter;
        _pageTipLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_pageTipLabel];
    }
    return _pageTipLabel;
}

- (UIToolbar *)toolBar{
    if ((!_toolBar)) {
        _toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 0, 30)];
        [_toolBar setBarStyle:UIBarStyleBlack];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleBack)];
        _toolBar.items = @[item];
        [self.view addSubview:_toolBar];
    }
    return _toolBar;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.toolBar addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat width = self.view.frame.size.width - 10;
        
        _layout = [UICollectionViewFlowLayout new];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(width, width * (9 / 16.));
        _layout.minimumLineSpacing = .1;
        
        CGRect frame = CGRectMake(0, 0, width, width * (9 / 16.));
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame
                                             collectionViewLayout:_layout];
        _collectionView.center = self.view.center;
        _collectionView.pagingEnabled = YES;
        
        
        [_collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:kBrowseCellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
        [self.view insertSubview:_collectionView belowSubview:self.pageTipLabel];
    }
    return _collectionView;
}


#pragma mark --handler
- (void)handleBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleFingerPinch:(UIPinchGestureRecognizer *)pincher
{
    if(UIGestureRecognizerStateEnded == pincher.state){
        CGRect layerFrame= pincher.view.layer.frame;
        
        if (layerFrame.size.width < self.layout.itemSize.width
            || layerFrame.size.height < self.layout.itemSize.height ) {
            self.fingerPinch.view.transform = CGAffineTransformMakeScale(1., 1.);
        }
    }
    if([pincher numberOfTouches]<2){
        return;
    }
    if(pincher.state==UIGestureRecognizerStateBegan)//set center
    {
        self.centerPoint = [pincher locationInView:pincher.view];
        pincher.scale=1.0;
    }
    [pincher.view.layer setAffineTransform:CGAffineTransformScale(pincher.view.transform, pincher.scale, pincher.scale)];//change the scale of the transform in Layer.
    pincher.scale=1.0;
    
    //set the new center point
    CGPoint nowPoint = [pincher locationInView:pincher.view];
    [pincher.view.layer setAffineTransform:
     CGAffineTransformTranslate(pincher.view.transform, nowPoint.x-self.centerPoint.x,nowPoint.y-self.centerPoint.y)];
    self.centerPoint=[pincher locationInView:pincher.view];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger numberOfTab = self.imageModels.count;
    return numberOfTab;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBrowseCellID
                                                                           forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor blackColor];
    
    static NSInteger kImageViewTag = 89898;
    UIImageView *imageView = [cell viewWithTag:kImageViewTag];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0,
                                                                  cell.frame.size.width - 10,
                                                                  cell.frame.size.height)];
        imageView.tag = kImageViewTag;
        [cell addSubview:imageView];
    }
    FYImageModel *imageModel = self.imageModels[indexPath.row];
    if (imageModel.urlString) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.urlString]];
    } else {
        imageView.image = [UIImage imageWithContentsOfFile:imageModel.localPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.fingerPinch.view.transform = CGAffineTransformMakeScale(1., 1.);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    self.fingerPinch.view.transform = CGAffineTransformMakeScale(1., 1.);

    // 得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageTipLabel.text = [NSString stringWithFormat:@"%d/%ld",currentPage + 1,
                                                                  self.imageModels.count];
    
    FYImageModel *imageModel = self.imageModels[currentPage];
    self.title = imageModel.title;
}

@end
