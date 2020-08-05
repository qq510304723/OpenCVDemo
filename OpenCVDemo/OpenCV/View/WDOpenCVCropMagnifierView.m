//
//  WDOpenCVCropMagnifierView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/5.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "WDOpenCVCropMagnifierView.h"

static CGFloat kCropMagnifierSize = 100.0f;

@interface WDOpenCVCropMagnifierView ()

@property (nonatomic, assign) CGPoint renderPoint;
@property (nonatomic, strong) UIView *renderView;

@end

@implementation WDOpenCVCropMagnifierView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, kCropMagnifierSize, kCropMagnifierSize)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = kCropMagnifierSize / 2;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.delegate = self;
        //保证和屏幕读取像素的比例一致
        self.layer.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    //提前位移半个长宽的坑
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, 1.5, 1.5);
    //再次位移后就可以把触摸点移至self.center的位置
    CGContextTranslateCTM(ctx, -1 * self.renderPoint.x, -1 * self.renderPoint.y);
    [self.renderView.layer renderInContext:ctx];
}

- (void)updateRenderPoint:(CGPoint)renderPoint renderView:(UIView *)renderView {
    self.renderPoint = renderPoint;
    self.renderView = renderView;
    [self.layer setNeedsDisplay];
}

@end
