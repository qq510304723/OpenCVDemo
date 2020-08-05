//
//  WDOpenCVCropCornerView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "WDOpenCVCropCornerView.h"

@implementation WDOpenCVCropCornerView

- (void)setPoint:(CGPoint)point {
    self.center = point;
}

- (CGPoint)point {
    return self.center;
}

@end
