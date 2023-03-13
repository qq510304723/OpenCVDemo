//
//  UIImageView+LHGContentRect.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "UIImageView+LHGContentRect.h"

@implementation UIImageView (LHGContentRect)

- (CGRect)shm_contentFrame {
    CGSize limitSize = self.bounds.size;
    CGSize scaledImageSize = [self shm_contentSize];
    CGRect imageFrame = CGRectMake(roundf(0.5f*(limitSize.width-scaledImageSize.width)), roundf(0.5f*(limitSize.height-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    return imageFrame;
}

- (CGSize)shm_contentSize {
    CGSize imageSize = self.image.size;
    CGFloat imageScale = [self shm_contentScale];
    CGSize finalSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    return finalSize;
}

- (CGFloat)shm_contentScale {
    CGSize imageSize = self.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds)/imageSize.width, CGRectGetHeight(self.bounds)/imageSize.height);
    return imageScale;
}

@end
