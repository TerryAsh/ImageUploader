//
//  FYImageUploader.h
//  OCTest
//
//  Created by 陈震 on 2017/8/9.
//  Copyright © 2017年 陈震. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FYImageModel.h"

@class FYImageUploader;

typedef void(^FYImageUploaderCallback)(FYImageUploader * uploader);

@interface FYImageUploader : NSObject

@property (nonatomic ,readonly) NSArray<FYImageModel *> *uploadingImages;
@property (nonatomic ,assign) NSInteger maxConcurrenceCount;//default is 5

- (instancetype)initWithImageModels:(NSArray<FYImageModel *> *) images;

- (void)startWithCallBack:(FYImageUploaderCallback) callback;
- (void)pause;
- (void)resume;
- (void)stop;

@end
