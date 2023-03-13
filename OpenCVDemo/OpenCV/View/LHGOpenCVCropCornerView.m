//
//  LHGOpenCVCropCornerView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "LHGOpenCVCropCornerView.h"

@implementation LHGOpenCVCropCornerView

- (void)setPoint:(CGPoint)point {
    self.center = point;
}

- (CGPoint)point {
    return self.center;
}

@end
