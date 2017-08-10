//
//  RWHImageModel.h
//  Pods
//
//  Created by zy on 16/11/16.
//
//  DESC 图片文件，缓存uiimage到硬盘，并被使用
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FYImageModel : NSObject
    
@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,readonly) NSString *localPath;


@property (nonatomic ,assign) double fractionCompleted;
@property (nonatomic ,assign) BOOL isUploadingFinished;

@property (nonatomic ,copy) NSString *qiniuHash;//七牛hash

 /**
  根据短文件名 将image从内存持久化到沙盒

  @param instancetype
  @return nil ,if image is bad
  */
+ (instancetype)imageModelWithUIImage:(UIImage *) imageInMemory
                         andImageName:(NSString *) name;

/*
 * 根据短文件名
 * 若不存在图片文件，就返回nil
 */
+ (instancetype)imageModelWithCertainNameFromDocument:(NSString *) imageFilename;

+ (void)clearAllImageModel;

- (NSString *)base64String;

@end
