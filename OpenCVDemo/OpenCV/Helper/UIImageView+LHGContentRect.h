//
//  UIImageView+LHGContentRect.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (LHGContentRect)

- (CGRect)shm_contentFrame;

- (CGFloat)shm_contentScale;

- (CGSize)shm_contentSize;

@end

NS_ASSUME_NONNULL_END
