//
//  LHGOpenCVEditingViewController.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LHGOpenCVEditingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol LHGOpenCVEditingViewControllerDelegate <NSObject>

@optional
- (void)editingController:(LHGOpenCVEditingViewController *)editor didFinishCropping:(UIImage *)finalCropImage;

@end

@interface LHGOpenCVEditingViewController : UIViewController

@property (nonatomic, weak) id<LHGOpenCVEditingViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *originImage;

// 自动提取四边形四个顶点
@property (nonatomic, assign) BOOL autoDectorCorner;

@end

NS_ASSUME_NONNULL_END
