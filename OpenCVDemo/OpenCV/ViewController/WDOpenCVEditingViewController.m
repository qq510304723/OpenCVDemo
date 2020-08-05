//
//  WDOpenCVEditingViewController.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "WDOpenCVEditingViewController.h"
#import "UIImageView+SHMContentRect.h"
#import "WDOpenCVCropFrameView.h"
#import "WDOpenCVCropMagnifierView.h"
#import "WDOpenCVUtils.h"
#import "WDOpenCVHelper.h"
#import "Masonry.h"

static CGFloat kWDOpenCVEditingImageMargin = 20.0;

@interface WDOpenCVEditingViewController () <WDOpenCVCropFrameViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WDOpenCVCropFrameView *cropFrameView;
@property (strong, nonatomic) WDOpenCVCropMagnifierView *magnifierView;

@end

@implementation WDOpenCVEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    CGFloat navHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
    CGRect imageFrame = CGRectZero;
    imageFrame.origin.x = kWDOpenCVEditingImageMargin;
    imageFrame.origin.y = kWDOpenCVEditingImageMargin + navHeight;
    imageFrame.size.width = CGRectGetWidth(self.view.frame) - kWDOpenCVEditingImageMargin * 2;
    imageFrame.size.height = CGRectGetHeight(self.view.frame) - imageFrame.origin.y - kWDOpenCVEditingImageMargin;
    
    self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    self.imageView.image = self.originImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    CGRect cropFrame = [self.imageView shm_contentFrame];
    cropFrame.origin.x += imageFrame.origin.x;
    cropFrame.origin.y += imageFrame.origin.y;
    self.cropFrameView = [[WDOpenCVCropFrameView alloc] initWithFrame:cropFrame];
    self.cropFrameView.delegate = self;
    [self.view addSubview:self.cropFrameView];
    
    self.magnifierView = [[WDOpenCVCropMagnifierView alloc] init];
    [self.view addSubview:self.magnifierView];
    self.magnifierView.hidden = YES;
    
    if (self.autoDectorCorner) {
        [WDOpenCVHelper asyncDetectQuadCornersWithImage:self.originImage targetSize:cropFrame.size completionHandler:^(NSDictionary<NSNumber *,NSValue *> * _Nullable quadPoints) {
            if (quadPoints.count == 4) {
                [quadPoints enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSValue * _Nonnull obj, BOOL * _Nonnull stop) {
                    [self.cropFrameView updatePointValue:obj.CGPointValue cornerType:key.integerValue];
                }];
            }
        }];
    }
}

#pragma mark - Navigation

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done {
    if (![self.cropFrameView isQuadEffective]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"所选区域无效" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    CGFloat scale = [self.imageView shm_contentScale];
    CGPoint topLeftPoint = [self.cropFrameView pointValueWithCornerType:WDOpenCVCornerTypeTopLeft];
    CGPoint topRightPoint = [self.cropFrameView pointValueWithCornerType:WDOpenCVCornerTypeTopRight];
    CGPoint bottomLeftPoint = [self.cropFrameView pointValueWithCornerType:WDOpenCVCornerTypeBottomLeft];
    CGPoint bottomRightPoint = [self.cropFrameView pointValueWithCornerType:WDOpenCVCornerTypeBottomRight];
    
    topLeftPoint.x /= scale;
    topLeftPoint.y /= scale;
    topRightPoint.x /= scale;
    topRightPoint.y /= scale;
    bottomLeftPoint.x /= scale;
    bottomLeftPoint.y /= scale;
    bottomRightPoint.x /= scale;
    bottomRightPoint.y /= scale;
    
    /*
    // 方案一：可能会拉伸变形
    NSMutableArray *vertexes = [NSMutableArray array];
    [vertexes addObject:[NSValue valueWithCGPoint:topLeftPoint]];
    [vertexes addObject:[NSValue valueWithCGPoint:topRightPoint]];
    [vertexes addObject:[NSValue valueWithCGPoint:bottomRightPoint]];
    [vertexes addObject:[NSValue valueWithCGPoint:bottomLeftPoint]];
    UIImage *cropImage1 = [WDOpenCVUtils getCorrectQuadImageWithImage:self.originImage vertexes:vertexes];
     */
    
    // 方案二：效果较好
    [WDOpenCVHelper asyncCropWithImage:self.originImage topLeftPoint:topLeftPoint topRightPoint:topRightPoint bottomLeftPoint:bottomLeftPoint bottomRightPoint:bottomRightPoint completionHandler:^(UIImage * _Nonnull retImage) {
        if ([self.delegate respondsToSelector:@selector(editingController:didFinishCropping:)]) {
            [self.delegate editingController:self didFinishCropping:retImage];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - WDOpenCVCropFrameViewDelegate

- (void)cropFrameView:(WDOpenCVCropFrameView *)cropFrameView didMoveToPoint:(CGPoint)point state:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan) {
        self.magnifierView.hidden = NO;
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        self.magnifierView.hidden = YES;
    }
    
    CGPoint renderPoint = [cropFrameView convertPoint:point toView:self.view];
    [self.magnifierView updateRenderPoint:renderPoint renderView:self.view];
    
    CGPoint magnifierCenter = [cropFrameView convertPoint:point toView:self.magnifierView.superview];
    magnifierCenter.y -= self.magnifierView.frame.size.height;
    self.magnifierView.center = magnifierCenter;
}

@end
