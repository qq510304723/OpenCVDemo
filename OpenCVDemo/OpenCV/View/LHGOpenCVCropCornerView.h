//
//  LHGOpenCVCropCornerView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHGOpenCVDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface LHGOpenCVCropCornerView : UIView

@property (nonatomic, assign) LHGOpenCVCornerType cornerType;

@property (nonatomic, assign) CGPoint point;

@end

NS_ASSUME_NONNULL_END
