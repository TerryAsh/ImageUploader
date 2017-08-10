//
//  FYImageUploader.m
//  OCTest
//
//  Created by 陈震 on 2017/8/9.
//  Copyright © 2017年 陈震. All rights reserved.
//

#import "FYImageUploader.h"
#import <AFNetworking/AFNetworking.h>

@interface FYImageUploader()

@property (nonatomic ,strong) NSMutableArray<FYImageModel *> *imageModels;
@property (nonatomic ,strong) NSString *token;//qiniu token
@property (nonatomic ,strong) NSOperationQueue *optQueue;
@property (copy) FYImageUploaderCallback callback;

@end

@implementation FYImageUploader
@synthesize uploadingImages = _uploadingImages;

- (instancetype)initWithImageModels:(NSArray<FYImageModel *> *)images{
    if (self = [super init]) {
        _uploadingImages = _imageModels = [[NSMutableArray alloc] initWithArray:images];
        _optQueue = [[NSOperationQueue alloc] init];
        _maxConcurrenceCount = 5;
        _optQueue.maxConcurrentOperationCount = _maxConcurrenceCount;
    }
    return self;
}

- (void)dealloc{
    [self.optQueue cancelAllOperations];
    self.optQueue = nil;
}

- (void)startWithCallBack:(FYImageUploaderCallback)callback{
    _callback = callback;
    
    [self _fetchToken];
    [self.imageModels enumerateObjectsUsingBlock:^(FYImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.optQueue addOperationWithBlock:^{
            [self _uploadImageModel:obj];
        }];
    }];
}

- (void)pause{
    [self.optQueue setSuspended:YES];
}

- (void)stop{
    [self.optQueue cancelAllOperations];
}

- (void)resume{
    [self.optQueue setSuspended:NO];
}

#pragma mark --setter

- (void)setMaxConcurrenceCount:(NSInteger)maxConcurrenceCount{
    if (maxConcurrenceCount != _maxConcurrenceCount) {
        _maxConcurrenceCount = maxConcurrenceCount;
        self.optQueue.maxConcurrentOperationCount = _maxConcurrenceCount;
    }
}

#pragma mark --private
- (void)_fetchToken{
    _token = @"f1oq_co39oKQlInFnn6hs-LSH0HMGE3RnaGBgtaY:hWGD0ZUc0AjgsWTULRzEgbG8aE4=:eyJzY29wZSI6InRlc3QiLCJkZWFkbGluZSI6MTUwMjM3OTU1Mn0=";
}

- (void)_uploadImageModel:(FYImageModel *)model{
    NSString *host = @"http://up-z2.qiniu.com/";
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.requestSerializer = [AFJSONRequestSerializer new];
    mgr.responseSerializer = [AFJSONResponseSerializer new];

    mgr.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];

    NSDictionary *para = @{@"token":self.token};
    [mgr POST:host parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data =  [NSData dataWithContentsOfFile:model.localPath];
        NSString *name = model.name;
        NSString *formKey = @"file";
        NSString *type = @"image/png";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%lf,%s",uploadProgress.fractionCompleted,__func__);
        model.fractionCompleted = uploadProgress.fractionCompleted;
        [self _doCallBack];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%s",__func__);
        model.isUploadingFinished = YES;
        [self _doCallBack];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@",%s",__func__);
        model.isUploadingFinished = YES;
        [self _doCallBack];
    }];
}

- (void)_doCallBack{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.callback) {
            self.callback(self);
        }
    });
}
@end
