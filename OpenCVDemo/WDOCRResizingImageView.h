//
//  WDOCRResizingImageView.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/3.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDOCRResizingImageView : UIView

@property (nonatomic, strong) UIImage *originImage;

/**
 四边形顶点坐标，必须是四个顶点
 */
@property (nonatomic, copy) NSArray <NSValue*> *quadVertexes;

@end

NS_ASSUME_NONNULL_END
