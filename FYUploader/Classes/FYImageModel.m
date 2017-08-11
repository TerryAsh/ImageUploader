//
//  RWHImageModel.m
//  Pods
//
//  Created by zy on 16/11/16.
//
//

#import "FYImageModel.h"

@implementation FYImageModel

+ (instancetype)imageModelWithUIImage:(UIImage *)imageInMemory
                         andImageName:(NSString *)name{
    FYImageModel *model = [FYImageModel new];
    model.name = name;
    //save to local
    NSData *imageData = UIImageJPEGRepresentation(imageInMemory, 1.0);
    NSURL *url = [NSURL fileURLWithPath:model.localPath];
    if (imageData) {
        [imageData writeToURL:url atomically:YES];
    } else{
        model = nil;
    }
    return model;
}

+ (instancetype)imageModelFromUrl:(NSString *)urlString{
    FYImageModel *model = [FYImageModel new];
    model.name = @"";
    //save to local
    if (urlString.length) {
        model.urlString = urlString;
    } else{
        model = nil;
    }
    return model;
}

+ (instancetype)imageModelWithCertainNameFromDocument:(NSString *) imageFilename{
    NSString *documentPath = [FYImageModel _imageDocumentPath];
    NSString *pathString = [documentPath stringByAppendingPathComponent:imageFilename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        FYImageModel *model = [FYImageModel new];
        model.name = imageFilename;
        return model;
    } else {
        return nil;
    }
}
    
- (NSString *)localPath{
    NSString *documentPath = [FYImageModel _imageDocumentPath];
    NSString *pathString = [documentPath stringByAppendingPathComponent:self.name];
    return pathString;
}
    
+ (NSString *)_imageDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"YLBImages"];
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return documentsDirectory;
}

+ (void)clearAllImageModel{
    NSString *documentPath = [FYImageModel _imageDocumentPath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:documentPath];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[documentPath stringByAppendingPathComponent:fileName] error:nil];
    }
}

- (NSString *)base64String{
    NSData *imageData = [NSData dataWithContentsOfFile:self.localPath];
    NSString *base64Encoded = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64Encoded;
}

@end
