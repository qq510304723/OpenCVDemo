//
//  LHGOpenCVHelper.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHGOpenCVHelper : NSObject

/**
 轮廓提取，并查找轮廓四个顶点
*/
+ (void)asyncDetectQuadCornersWithImage:(UIImage *)image
                             targetSize:(CGSize)targetSize
                      completionHandler:(void (^)(NSDictionary <NSNumber*,NSValue*> *_Nullable quadPoints))completionHandler;

/**
 获取纠偏后的图像
 */
+ (void)asyncCropWithImage:(UIImage *)image
              topLeftPoint:(CGPoint)topLeftPoint
             topRightPoint:(CGPoint)topRightPoint
           bottomLeftPoint:(CGPoint)bottomLeftPoint
          bottomRightPoint:(CGPoint)bottomRightPoint
         completionHandler:(void (^)(UIImage *retImage))completionHandler;

@end

NS_ASSUME_NONNULL_END
