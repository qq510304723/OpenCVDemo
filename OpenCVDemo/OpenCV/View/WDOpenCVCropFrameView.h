//
//  WDOpenCVCropFrameView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDOpenCVDefines.h"

@class WDOpenCVCropFrameView;

NS_ASSUME_NONNULL_BEGIN

@protocol WDOpenCVCropFrameViewDelegate <NSObject>

@optional
- (void)cropFrameView:(WDOpenCVCropFrameView *)cropFrameView didMoveToPoint:(CGPoint)point state:(UIGestureRecognizerState)state;

@end

@interface WDOpenCVCropFrameView : UIView

@property (nonatomic, weak) id<WDOpenCVCropFrameViewDelegate> delegate;

@property (nonatomic, strong) UIColor *cornerFillColor;

@property (nonatomic, strong) UIColor *lineSuccessColor;

@property (nonatomic, strong) UIColor *lineFailureColor;

// 有效矩形区域
@property (nonatomic, assign) BOOL isQuadEffective;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updatePointValue:(CGPoint)point cornerType:(WDOpenCVCornerType)cornerType;

- (CGPoint)pointValueWithCornerType:(WDOpenCVCornerType)cornerType;

@end

NS_ASSUME_NONNULL_END
