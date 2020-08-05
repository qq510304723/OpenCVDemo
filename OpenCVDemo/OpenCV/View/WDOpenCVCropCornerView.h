//
//  WDOpenCVCropCornerView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDOpenCVDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface WDOpenCVCropCornerView : UIView

@property (nonatomic, assign) WDOpenCVCornerType cornerType;

@property (nonatomic, assign) CGPoint point;

@end

NS_ASSUME_NONNULL_END
