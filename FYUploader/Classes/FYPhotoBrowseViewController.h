//
//  FYPhotoBrowseViewController.h
//  Pods
//
//  Created by 陈震 on 2017/8/11.
//
//

#import <UIKit/UIKit.h>
#import "FYImageModel.h"

@interface FYPhotoBrowseViewController : UIViewController

@property (nonatomic ,strong) NSArray<FYImageModel *> *imageModels;

@end
