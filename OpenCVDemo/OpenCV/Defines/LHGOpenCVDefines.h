//
//  LHGOpenCVDefines.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#ifndef LHGOpenCVDefines_h
#define LHGOpenCVDefines_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define CVLogDebug(args, ...) NSLog(args, ##__VA_ARGS__)
#else
#define CVLogDebug(args, ...)
#endif

typedef NS_ENUM(NSUInteger, LHGOpenCVCornerType) {
    LHGOpenCVCornerTypeTopLeft       = 1,
    LHGOpenCVCornerTypeTopRight      = 2,
    LHGOpenCVCornerTypeBottomLeft    = 3,
    LHGOpenCVCornerTypeBottomRight   = 4,
};

#endif /* LHGOpenCVDefines_h */
