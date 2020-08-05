//
//  WDOpenCVEditingViewController.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDOpenCVEditingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol WDOpenCVEditingViewControllerDelegate <NSObject>

@optional
- (void)editingController:(WDOpenCVEditingViewController *)editor didFinishCropping:(UIImage *)finalCropImage;

@end

@interface WDOpenCVEditingViewController : UIViewController

@property (nonatomic, weak) id<WDOpenCVEditingViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *originImage;

// 自动提取四边形四个顶点
@property (nonatomic, assign) BOOL autoDectorCorner;

@end

NS_ASSUME_NONNULL_END
