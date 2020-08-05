//
//  WDOpenCVUtils.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDOpenCVUtils : NSObject

/**
 二值化
 */
+ (UIImage *)RGB2GrayWithImage:(UIImage *)image;

/**
 高斯滤波
 */
+ (UIImage *)gaussianBlurWithImage:(UIImage *)image;

/**
 膨胀操作
 */
+ (UIImage *)dilateWithImage:(UIImage *)image;

/**
 边缘提取
 */
+ (UIImage *)cannyExtractionWithImage:(UIImage *)imag;

/**
 轮廓查找并筛选
 */
+ (UIImage *)showContoursWithImage:(UIImage *)image;

/**
 找四边形轮廓四个顶点
 */
+ (NSArray *)findContoursVertexWithBlackContourImage:(UIImage *)contourImage sourceImage:(UIImage *)sourceImage;

/**
 获取纠偏后的图像
 */
+ (UIImage *)getCorrectQuadImageWithImage:(UIImage *)image vertexes:(NSArray <NSValue*> *)vertexes;

@end

NS_ASSUME_NONNULL_END
