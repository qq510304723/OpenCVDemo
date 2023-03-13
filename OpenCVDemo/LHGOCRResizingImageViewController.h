//
//  LHGOCRResizingImageViewController.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/3.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHGOCRResizingImageViewController : UIViewController

- (instancetype)initWithImage:(nullable UIImage *)image;

@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
